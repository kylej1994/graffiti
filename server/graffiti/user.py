import boto3
import json
import sys
import re
import types
sys.path.append('..')
from graffiti import db, s3_client
from sqlalchemy import Column, Float, Integer, String

from datetime import datetime
from time import time

import geoalchemy2
import re
EMAIL_REGEX = re.compile(r"[^@]+@[^@]+\.[^@]+")

class User(db.Model):
    __tablename__ = 'users'

    # Only alnum or _ in username. Between 3 and 25 chars inclusive
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    google_aud = db.Column(db.String(100), unique=True)
    username = db.Column(db.String(100), unique=True)
    # Presented as 10 digits in a row. Dashes will be removed in validation.
    phone_number = db.Column(db.String(100))
    name = db.Column(db.String(100))
    email = db.Column(db.String(100), unique=True)
    bio = db.Column(db.String(160))
    join_timestamp = db.Column(db.DateTime)
    has_been_suspended = db.Column(db.Boolean)

    def __init__(self, username, google_aud, phone_number, name, email, bio):
        self.set_username(username)
        self.set_google_aud(google_aud)
        self.set_phone_number(phone_number)
        self.set_name(name)
        self.set_email(email)
        self.join_timestamp = datetime.fromtimestamp(time()).isoformat()
        self.set_bio(bio)
        self.has_been_suspended = False

    def __repr__(self):
        return '<username {}>'.format(self.username)

    # Only alnum or _ in username. Between 3 and 25 chars inclusive.
    def validate_username(self, username):
        if (len(username) > 25 or len(username) < 3):
            return False
        return True

    # Only alpha and whitespace. Fewer than or equal to 50 characters.
    def validate_name(self, name):
        if (len(name) > 50 or not re.match('^[\d\s\w]+$', name)):
            return False
        return True

    def validate_phone_number(self, phone_number):
        new_number = re.sub('-', '', phone_number)
        if (len(new_number) == 11 and new_number[0] == '1'):
            new_number = new_number[1:]
        if (not new_number.isdigit() or len(new_number) != 10):
            return None

        return new_number

    def get_user_id(self):
        return self.user_id

    def get_google_aud(self):
        return self.google_aud

    def get_username(self):
        return self.username

    def get_phone_number(self):
        return self.phone_number

    def get_name(self):
        return self.name

    def get_email(self):
        return self.email

    def get_bio(self):
        return self.bio

    def get_join_timestamp(self):
        return self.join_timestamp

    def get_has_been_suspended(self):
        return self.has_been_suspended

    # uploads img_data to s3 as this user's img tag
    def set_image_tag(self, img_data):
        try:
            key = 'userid:{0}, joined:{1}'.format(self.user_id,\
                self.join_timestamp)
            s3_client.put_object(Body=img_data,\
                Bucket='graffiti-user-images',\
                Key=key)
            return True
        except Exception, e:
            print e
            return False

    # No validations implemented
    def set_google_aud(self, google_aud):
        self.google_aud = google_aud
        return True

    # Only alnum or _ in username. Between 3 and 25 chars inclusive.
    def set_username(self, username):
        if (self.validate_username(username)):
            self.username = username
            return True
        else:
            return False

    # Updates by removing country code 1, remove dashes
    def set_phone_number(self, phone_number):
        new_number = self.validate_phone_number(phone_number)
        if (new_number != None):
            self.phone_number = new_number
            return True
        else:
            return False

    # Only letters
    def set_name(self, name):
        if (self.validate_name(name)):
            self.name = name
            return True
        else:
            return False

    def set_bio(self, bio):
        self.bio = bio
        return True

    def set_email(self, email):
        if not EMAIL_REGEX.match(email):
            return False
        self.email = email
        return True

    # Only bool
    def set_has_been_suspended(self, suspended):
        if (type(suspended) == types.BooleanType):
            self.has_been_suspended = suspended
            return True
        else:
            return False

    def to_json_fields_for_FE(self):
        img_data = []
        # retrieve image data from s3 if there is an image tag
        key = 'userid:{0}, joined:{1}'.format(self.user_id,\
            self.join_timestamp)
        try:
            img_data = s3_client.get_object(\
                Bucket='graffiti-user-images',\
                Key=key)['Body'].read().decode('ascii')
        except:
            print('Error retrieving image tag: ' + key)
        return json.dumps(dict(
            userid=self.user_id,
            username=self.username,
            name=self.name,
            email=self.email,
            bio=self.bio,
            phone_number=self.phone_number,
            img_tag=img_data))

    # saves the user into the db
    def save_user(self):
        db.session.add(self)
        db.session.commit()

    # deletes the user from the db
    def delete_user(self):
        db.session.delete(self)
        db.session.commit()

    # finds a user given a google_aud
    @staticmethod
    def get_user_by_google_aud(aud):
        return db.session.query(User).filter(User.google_aud==aud).first()

    # finds a user given a user id
    # returns None if user_id is not in the db
    @staticmethod
    def find_user_by_id(user_id):
        return db.session.query(User).filter(User.user_id==user_id).first()

    # finds a user given a username
    # returns None if username is not in the db
    @staticmethod
    def find_user_by_username(username):
        return db.session.query(User).filter(User.username==username).first()
