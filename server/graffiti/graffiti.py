import boto3
import botocore
import json
import auth_Middleware

from flask import Flask, request, abort
from oauth2client import client, crypt
from flask.ext.sqlalchemy import SQLAlchemy

import os
DB = ''
if 'GRAFFITI_DB' in os.environ:
	DB = os.environ['GRAFFITI_DB']

app = Flask(__name__)
app.config.from_pyfile('graffiti.cfg')
if DB:
	app.config['SQLALCHEMY_DATABASE_URI'] = DB
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = 200 * 1024 * 1024
db = SQLAlchemy(app)
app.wsgi_app = auth_Middleware.Auth_MiddleWare(app.wsgi_app)

if 'S3_ACCESS_KEY' in os.environ and 'S3_SECRET_KEY' in os.environ:
	S3_ACCESS_KEY = os.environ['S3_ACCESS_KEY']
	S3_SECRET_KEY = os.environ['S3_SECRET_KEY']

	cfg = botocore.config.Config(signature_version='s3v4')
	s3_client = boto3.client('s3', config=cfg,\
	    aws_access_key_id=S3_ACCESS_KEY,\
	    aws_secret_access_key=S3_SECRET_KEY)
else:
	print('Couldn\'t connect to s3 client')


def generate_error_response(message, code):
	error_response = {}
	error_response['error'] = message
	return json.dumps(error_response), code

# common to both post_api and user_api, so definiting it here
def retrieve_user_from_request(request):
	info = request.environ['META_INFO']
	no_id = request.environ['NOID']
	bad_token = request.environ['BADTOKEN']
	if (info is None or no_id or bad_token):
		return None
	
	return User.get_user_by_google_aud(info['audCode'])

@app.route('/initdb')
def init_db():
	db.session.commit()
	db.drop_all()
	db.create_all()
	return 'initted the db\n'

# These imports must happen after the initialization of the db because these
# objects import db in their respective files.
from post import Post
from user import User
from userpost import UserPost

from post_api import post_api
from user_api import user_api

app.register_blueprint(user_api)
app.register_blueprint(post_api)

# FOR TESTING PURPOSES ONLY
@app.route('/cleardb')
def clear_db_of_everything():
	# need this otherwise postgresql freezes
	db.session.commit()
	db.session.close_all()
	db.drop_all()
	return 'dropped\n'

# FOR TESTING PURPOSES ONLY
@app.route('/filldb')
def fill_db():
	# Sample values
	db.create_all()
	db.session.add(User('easmith', \
		'1008719970978', \
		'9172825753', \
		'Emma Smith', \
		'kat@lu.com', \
		'My name is jablonk'))
	db.session.add(User('user2', \
		'1008719970979', \
		'1234567801', \
		'Smith Emma', \
		'lu@kat.com', \
		'My name is jablonkadonk'))
	db.session.add(Post('text', 51.5192028, -0.140863, 1))
	db.session.add(Post('text2', 51.5192028, -0.140863, 1))
	db.session.add(Post('post_location_1', -51.5192028, 0.140863, 1))
	db.session.add(Post('post_location_2', -51.5192028, 0.140863, 1))
	db.session.add(Post('post_location_2', -51.5192028, 0.140863, 2))
	db.session.commit()
	return 'added sample records\n'

# If its the default db, i.e. the local db
if not DB or DB == 'postgresql://localhost/mydb':
	print init_db()
	print clear_db_of_everything()
	print fill_db()

def generate_error_response(message, code):
	error_response = {}
	error_response['error'] = message
	return json.dumps(error_response), code

@app.route('/')
def hello():
	#meta_info = request.environ['META_INFO']
	#if (meta_info is None):
#		return generate_error_response('Missing idToken.', 401)
	return 'Success.\n'
