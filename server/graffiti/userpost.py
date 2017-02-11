sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String

from datetime import datetime
from time import time

import geoalchemy

class UserPost(db.Model):
    __tablename__ = 'userpost'

    username = db.Column(db.String(100), db.ForeignKey('user.username'), primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('post.post_id'), primary_key=True)
    vote = db.Column(db.Integer)

    def __init__(self, username, post_id, vote):
        self.username = username
        self.post_id = post_id
        self.vote = vote

    def __repr__(self):
        return '<username {}'.format(self.username) + ' post_id {}>'.format(self.post_id)