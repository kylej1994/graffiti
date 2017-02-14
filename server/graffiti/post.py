import json
import sys
sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String
from sqlalchemy.dialects.postgresql import JSON

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
    poster_aud = db.Column(db.String(100))
    num_votes = db.Column(db.Integer)

    def __init__(self, text, longitude, latitude, poster_id, poster_aud):
        self.text = text
        self.longitude = longitude
        self.latitude = latitude
        self.created_at = datetime.fromtimestamp(time()).isoformat()
        self.poster_username = posted_id
        self.poster_aud = poster_aud
        self.num_votes = 0

    def __repr__(self):
        return '<post_id {}>'.format(self.post_id)

    def to_json_fields_for_FE(self):
        return json.dumps(dict(
            postid=self.post_id,
            text=self.text,
            location=dict(
                longitude=self.longitude,
                latitude=self.latitude),
            created_at=str(self.created_at),
            posterid=poster_id,
            num_votes=self.num_votes))
