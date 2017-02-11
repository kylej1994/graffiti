sys.path.append('..')
from graffiti import db
from sqlalchemy import Column, Float, Integer, String

from datetime import datetime
from time import time

import geoalchemy

class User(db.Model):
    __tablename__ = 'user'

    # Only alnum or _ in username. <25 chars. Will be enforced in validation.
    username = db.Column(db.String(100), primary_key=True, unique=True)
    google_aud = db.Column(db.String(100), primary_key=True, unique=True)
    # Presented as 10 digits in a row. Dashes will be removed in validation.
    phone_number = db.Column(db.String(100), unique=True)
    join_timestamp = db.Column(db.DateTime)
    has_been_suspended = db.Column(db.Boolean)

    def __init__(self, username, google_aud, phone_number):
        self.username = ""
        self.phone_number = ""
        # We have not yet implemented the parameter validation methods 
        if (validate_username(username)){
            self.username = username
        }
        if (validate_phone_number(phone_number)){
            self.phone_number = phone_number
        }
        self.google_aud = google_aud
        self.join_timestamp = datetime.fromtimestamp(time()).strftime('%Y-%m-%d %H:%M:%S')
        self.has_been_suspended = False

    def __repr__(self):
        return '<username {}>'.format(self.username)