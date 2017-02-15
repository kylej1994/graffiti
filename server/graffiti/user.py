import json
import sys
sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String

from datetime import datetime
from time import time

import geoalchemy2

class User(db.Model):
    __tablename__ = 'user'

    # Only alnum or _ in username. <25 chars. Will be enforced in validation.
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    google_aud = db.Column(db.String(100), unique=True)
    username = db.Column(db.String(100), unique=True)
    # Presented as 10 digits in a row. Dashes will be removed in validation.
    phone_number = db.Column(db.String(100), unique=True)
    name = db.Column(db.String(100))
    email = db.Column(db.String(100), unique=True)
    text_tag = db.Column(db.String(160))
    join_timestamp = db.Column(db.DateTime)
    has_been_suspended = db.Column(db.Boolean)

    def __init__(self, username, google_aud, phone_number, name, email, text_tag):
        self.username = ""
        self.phone_number = ""
        # We have not yet implemented the parameter validation methods 
        if (self.validate_username(username)):
            self.username = username
        if (self.validate_phone_number(phone_number)):
            self.phone_number = phone_number

        self.google_aud = google_aud
        self.name = name
        self.email = email
        self.text_tag = text_tag
        self.join_timestamp = datetime.fromtimestamp(time()).isoformat()
        self.has_been_suspended = False

    def __repr__(self):
        return '<username {}>'.format(self.username)

    def validate_username(self, username):
        return True

    def validate_phone_number(self, phone_number):
        return True

    def to_json_fields_for_FE(self):
        return json.dumps(dict(
            userid=self.user_id,
            username=self.username,
            name=self.name,
            email=self.email,
            textTag=self.text_tag))