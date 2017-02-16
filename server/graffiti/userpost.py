sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String

from datetime import datetime
from time import time

import geoalchemy

class UserPost(db.Model):
    __tablename__ = 'userpost'

    user_id = db.Column(db.String(100), db.ForeignKey('user.user_id'), primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('post.post_id'), primary_key=True)
    vote = db.Column(db.Integer)

    def __init__(self, user_id, post_id, vote):
        # Set parameters
        self.user_id = user_id
        self.post_id = post_id
        self.vote = vote

    def __repr__(self):
        return '<username {}'.format(self.username) + ' post_id {}>'.format(self.post_id)

    def get_username(self):
        return username

    def get_post_id(self):
        return post_id

    def get_vote(self):
        return vote

    def set_vote(self, vote):
        self.vote = vote
        db.session.commit()
