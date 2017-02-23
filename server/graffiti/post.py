import json
import sys
sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String
from sqlalchemy.dialects.postgresql import JSON
from user import User
from userpost import UserPost

import time

from geoalchemy2.elements import WKTElement
from geoalchemy2.functions import ST_DFullyWithin
from geoalchemy2.shape import from_shape
from geoalchemy2 import Geometry
from shapely.geometry import Point

class Post(db.Model):
    __tablename__ = 'post'

    post_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    text = db.Column(db.String(100))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    loc = db.Column(Geometry(geometry_type='POINT', srid=4326))
    created_at = db.Column(db.Float)
    poster_id = db.Column(db.Integer)
    num_votes = db.Column(db.Integer)

    def __init__(self, text, longitude, latitude, poster_id):
        self.text = text
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
        cur_user_vote = UserPost.get_vote_by_id(current_user_id, self.post_id)
        cur_user_vote = cur_user_vote if cur_user_vote else 0
        return json.dumps(dict(
            postid=self.post_id,
            text=self.text,
            location=dict(
                longitude=self.longitude,
                latitude=self.latitude),
            created_at=self.created_at,
            poster=user.to_json_fields_for_FE(),
            num_votes=self.num_votes,
            current_user_vote=cur_user_vote))

    def get_poster_id(self):
        return self.poster_id

    def get_text(self):
        return self.text

    # saves the post into the db
    def save_post(self):
        db.session.add(self)
        db.session.commit()

    # deletes the post from the db
    def delete_post(self):
        db.session.delete(self)
        db.session.commit()

    def set_vote(self, vote):
        self.num_votes += vote
        db.session.commit()


    # applies the vote to the post given a user_id, post_id, and vote
    # returns true if the vote could be applied, false otherwise
    # right now, if a user votes, then they cannot change their vote
    @staticmethod
    def apply_vote(user_id, post_id, vote):
        userpost = db.session.query(UserPost).filter(UserPost.post_id==post_id)\
            .filter(UserPost.user_id==user_id).first()
        # if the post has not been voted on by this user, we create an entry
        # and add it to the db
        if userpost is None:
            userpost = UserPost(user_id, post_id, vote)
            db.session.add(userpost)
        elif userpost.get_vote() == 0:
            userpost.set_vote(vote)
        else:
            return False
        post = Post.find_post(post_id)
        post.num_votes += vote
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
        return db.session.query(Post).filter(Post.poster_id==user_id).all()

    # finds posts within a certain radius of a coordinate
    @staticmethod
    def find_posts_within_loc(lon, lat, radius):
        distance = radius * 0.014472 #convert to degrees
        loc = 'POINT(' + str(lat) + ' ' + str(lon) + ')'
        wkt_element = WKTElement(loc, srid=4326)
        posts = db.session.query(Post).filter(ST_DFullyWithin(\
            Post.loc, wkt_element, distance)).all()
        return posts


