sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String

from datetime import datetime
from time import time

import geoalchemy

class Post(db.Model):
    __tablename__ = 'post'

    post_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    text = db.Column(db.String(100))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    #loc = db.Column(Geography(geometry_type='POINT', srid=4326))
    created_at = db.Column(db.DateTime)
    poster_username = db.Column(db.String(30))
    num_votes = db.Column(db.Integer)

    def __init__(self, text, longitude, latitude, poster_username):
        self.text = text
        self.longitude = longitude
        self.latitude = latitude
        self.created_at = datetime.fromtimestamp(time()).strftime('%Y-%m-%d %H:%M:%S')
        self.poster_username = poster_username
        self.num_votes = 0

    def __repr__(self):
        return '<post_id {}>'.format(self.post_id)
