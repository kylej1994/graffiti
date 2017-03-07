import json
import sys
sys.path.append('..')
from graffiti import db, s3_client
from sqlalchemy import Column, Float, Integer, String
from sqlalchemy.dialects.postgresql import JSON
from user import User
from userpost import UserPost

import boto3
import enum
import time

from geoalchemy2.elements import WKTElement
from geoalchemy2.functions import ST_DFullyWithin
from geoalchemy2.shape import from_shape
from geoalchemy2 import Geometry
from shapely.geometry import Point


class Post(db.Model):
    __tablename__ = 'post'


    class PostType(enum.Enum):
        TEXT = 0
        IMAGE = 1

        def describe(self):
            return self.value

    post_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    post_type = db.Column(db.Enum(PostType))
    text = db.Column(db.Unicode(140))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    loc = db.Column(Geometry(geometry_type='POINT', srid=4326))
    created_at = db.Column(db.Float)
    poster_id = db.Column(db.Integer)
    num_votes = db.Column(db.Integer)

    # defaults for type because I don't want to break things everywhere else
    def __init__(self, text, longitude, latitude, poster_id, post_type = 0):
        self.text = unicode(text)
        self.post_type = Post.PostType(int(post_type))
        self.longitude = longitude
        self.latitude = latitude
        self.created_at = time.time()
        self.poster_id = poster_id
        self.num_votes = 0
        # latitude comes first
        loc = 'POINT(' + str(latitude) + ' ' + str(longitude) + ')'
        self.loc = WKTElement(loc, srid=4326)


    def __repr__(self):
        return '<post_id {}>'.format(self.post_id)

    def to_json_fields_for_FE(self, current_user_id):
        user = User.find_user_by_id(self.poster_id)
        cur_user_vote = UserPost.get_vote_by_ids(current_user_id, self.post_id)
        cur_user_vote = cur_user_vote if cur_user_vote else 0

        img_data = []
        # retrieve image data from s3 if its an image
        if self.post_type.describe() == 1:
            key = self.get_s3_key()
            try:
                img_data = s3_client.get_object(\
                    Bucket='graffiti-post-images',\
                    Key=key)['Body'].read().decode('ascii')
            except:
                print('Error retrieving image post: ' + key)
        return json.dumps(dict(
            postid=self.post_id,
            type=self.post_type.describe(),
            text=self.text,
            location=dict(
                longitude=self.longitude,
                latitude=self.latitude),
            created_at=self.created_at,
            poster=json.loads(user.to_json_fields_for_FE()),
            num_votes=self.num_votes,
            current_user_vote=cur_user_vote,
            image=img_data))

    def get_poster_id(self):
        return self.poster_id

    def get_text(self):
        return self.text

    def get_longitude(self):
        return self.longitude

    def get_latitude(self):
        return self.latitude

    def get_s3_key(self):
        created_at = int(self.created_at)
        return 'postid:{0}&created_at:{1}'.format(self.post_id,\
                    created_at)

    def upload_img_to_s3(self, img_data):
        # if its an image, upload it to s3
        if self.post_type.describe() == 1:
            key = self.get_s3_key()
            try:
                s3_client.put_object(Body=img_data,\
                    Bucket='graffiti-post-images',\
                    Key=key)
            except:
                print('Error uploading image post: ' + key)
        # if not, do nothing
        # doing this for compatability reasons...wow this code is smelly

    def get_img_file_loc(self):
        key = self.get_s3_key()
        url = '{}/{}/{}'.format(s3_client.meta.endpoint_url, 'graffiti-post-images', key)
        return url
 

    # saves the post into the db
    def save_post(self):
        db.session.add(self)
        db.session.commit()

    # deletes the post from the db
    def delete_post(self):
        db.session.delete(self)
        db.session.commit()

    def set_vote(self, vote):
        self.num_votes = vote
        db.session.commit()

    def increment_vote(self, vote):
        self.num_votes += vote
        db.session.commit()


    # applies the vote to the post given a user_id, post_id, and vote
    # returns true if the vote could be applied, false otherwise
    # right now, if a user votes, then they cannot change their vote
    @staticmethod
    def apply_vote(user_id, post_id, vote):

        #if the post dne, return false
        post = Post.find_post(post_id)
        if post is None:
            return False

        userpost = db.session.query(UserPost).filter(UserPost.post_id==post_id,\
            UserPost.user_id==user_id).first()
        # if the post has not been voted on by this user, we create an entry
        # and add it to the db

        # Standardize values
        if (vote > 1):
            vote = 1;
        elif (vote < -1):
            vote = -1;

        # Edit userpost table
        if userpost is None:
            userpost = UserPost(user_id, post_id, vote)
            db.session.add(userpost)
            difference = vote
        else:
            currentvote = userpost.get_vote()
            difference = vote - currentvote
            userpost.set_vote(vote)

        # Change value of votes on that post
        post = Post.find_post(post_id)
        post.increment_vote(difference)

        db.session.commit()
        return True

    # finds a post given a post id
    # returns None if post_id is not in the db
    @staticmethod
    def find_post(postid):
        return db.session.query(Post).filter(Post.post_id==postid).first()

    # finds all post of a given user_id
    @staticmethod
    def find_user_posts(user_id):
        return db.session.query(Post).filter(Post.poster_id==user_id).order_by(\
            Post.created_at.desc()).all()

    # finds image posts within a certain radius of a coordinate
    # cap of 15 image posts
    @staticmethod
    def find_image_posts_within_loc(lon, lat, radius):
        distance = radius * 0.014472 #convert to degrees
        loc = 'POINT(' + str(lat) + ' ' + str(lon) + ')'
        wkt_element = WKTElement(loc, srid=4326)
        posts = db.session.query(Post).filter(Post.post_type.describe()==1,\
            ST_DFullyWithin(Post.loc, wkt_element, distance))\
            .order_by(Post.created_at.desc()).limit(15)
        return posts

    # finds posts within a certain radius of a coordinate
    @staticmethod
    def find_text_posts_within_loc(lon, lat, radius):
        distance = radius * 0.014472 #convert to degrees
        loc = 'POINT(' + str(lat) + ' ' + str(lon) + ')'
        wkt_element = WKTElement(loc, srid=4326)
        posts = db.session.query(Post).filter(Post.post_type.describe()==0,\
            ST_DFullyWithin(Post.loc, wkt_element, distance))\
            .order_by(Post.created_at.desc()).all()
        return posts
