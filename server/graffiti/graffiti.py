import boto3
import botocore
import json
import auth_Middleware

from flask import Flask, request, abort
from oauth2client import client, crypt
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config.from_pyfile('graffiti.cfg')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = 200 * 1024 * 1024
db = SQLAlchemy(app)
app.wsgi_app = auth_Middleware.Auth_MiddleWare(app.wsgi_app)

# obviously will put this somewhere else eventually
ACCESS_KEY = 'AKIAIDBIJ3JOX3LDGVNQ'
SECRET_KEY = '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'

cfg = botocore.config.Config(signature_version='s3v4')
s3_client = boto3.client('s3', config=cfg,\
    aws_access_key_id=ACCESS_KEY,\
    aws_secret_access_key=SECRET_KEY)	


@app.route('/initdb')
def init_db():
	db.session.commit()
	db.drop_all()
	db.create_all()
	return 'initted the db\n'

print init_db()

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
