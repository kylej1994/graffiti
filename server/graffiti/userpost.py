import sys
sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String

from datetime import datetime
from time import time

import geoalchemy2

class UserPost(db.Model):
    __tablename__ = 'userpost'

    user_id = db.Column(db.Integer, db.ForeignKey('user.user_id'), primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('post.post_id'), primary_key=True)
    vote = db.Column(db.Integer)

    def __init__(self, user_id, post_id, vote):
        # Set parameters
        self.user_id = user_id
        self.post_id = post_id
        self.vote = vote

    def __repr__(self):
        return '<username {}'.format(self.username) + ' post_id {}>'.format(self.post_id)

    def get_user_id(self):
        return self.user_id

    def get_post_id(self):
        return self.post_id

    def get_vote(self):
        return self.vote

    def set_vote(self, vote):
        self.vote = vote
        db.session.commit()

    @staticmethod
    def get_post_vote_by_user(user_id, post_id):
        return db.session.query(UserPost).filter(UserPost.post_id==post_id and \
            UserPost.user_id==user_id).first().get_vote()