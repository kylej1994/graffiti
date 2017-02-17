import json
import sys
sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String
from sqlalchemy.dialects.postgresql import JSON
from user import User

from datetime import datetime
from time import time

import geoalchemy2

class Post(db.Model):
    __tablename__ = 'post'

    post_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    text = db.Column(db.String(100))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    #loc = db.Column(Geography(geometry_type='POINT', srid=4326))
    created_at = db.Column(db.DateTime)
    poster_id = db.Column(db.Integer)
    num_votes = db.Column(db.Integer)

    def __init__(self, text, longitude, latitude, poster_id):
        self.text = text
        self.longitude = longitude
        self.latitude = latitude
        self.created_at = datetime.fromtimestamp(time()).isoformat()
        self.poster_id = poster_id
        self.num_votes = 0

    def __repr__(self):
        return '<post_id {}>'.format(self.post_id)

    def to_json_fields_for_FE(self):
        user = db.session.query(User).filter(User.user_id==self.poster_id).first()
        return json.dumps(dict(
            postid=self.post_id,
            text=self.text,
            location=dict(
                longitude=self.longitude,
                latitude=self.latitude),
            created_at=str(self.created_at),
            poster=user.to_json_fields_for_FE(),
            num_votes=self.num_votes))

    def get_poster_id(self):
        return self.poster_id;

    # saves the post into the db
    def save_post(self):
        db.session.add(self)
        db.session.commit()

    # deletes the post from the db
    def delete_post(self):
        db.session.delete(self)
        db.session.commit()

    # applies the vote to the post
    def set_vote(self, vote):
        self.num_votes += vote
        db.session.commit()

    # finds a post given a post id
    # returns None if post_id is not in the db
    # NOTE will this conflict with the namespace of the DB model???
    @staticmethod
    def find_post(postid):
        return db.session.query(Post).filter(Post.post_id==postid).first()

    # finds all post of a given user_id
    @staticmethod
    def find_user_posts(user_id):
        return db.session.query(Post).filter(Post.poster_id==user_id)

    # finds posts within a certain radius of a coordinate
    @staticmethod
    def find_posts_within_loc(lon, lat, radius):
        distance = radius * 0.014472 #convert to degrees
        center_point = Point(lon, lat)
        wkb_element = from_shape(center_point)
        posts = db.session.query(Post).filter(func.ST_DFullyWithin(\
            Point(Post.longitude, Post.latitude), wkb_element, distance)).all()
        return posts


