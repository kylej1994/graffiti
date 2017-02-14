import json

from flask import Blueprint, request
from user import User

user_api = Blueprint('user_api', __name__)

from graffiti import db

fake_response = json.dumps(dict(
		userid=1,
		username='hothjylewis',
		name="Hot and Bothered",
		email="comeNfind@me.com",
		textTag="Yum yum yum!"))

@user_api.route('/user/login', methods=['GET'])
def user_login():
	# no checking of authentication is happening yet...
	print 'in create user'
	
	# if this user is a new user
	# create new User object with next userId and empty strings for other fields
	# else, login with idToken passed in through header
	# return whether its a new user and the associated user object

	return json.dumps(dict(
		new_user='No',
		user=fake_response))

@user_api.route('/user/<int:userid>', methods=['GET'])
def get_user(userid):
	# no checking of authentication is happening yet...
	
	# look for user based on userid 
	# return user object if found
	# return 404 otherwise

	user = db.session.query(User).filter(User.user_id==userid).first()
	
	if (user is None):
		error_response = {}
		error_response['error'] = "User not found."
		return json.dumps(error_response), 404

	return user.to_json_fields_for_FE()

@user_api.route('/user/<int:userid>', methods=['PUT'])
def update_user(userid):
	# no checking of authentication is happening yet...
	data = request.get_json()
	
	# checks for necessary data params
	if ('userid' not in data or int(data['userid']) != userid):
		error_response = {}
		error_response['error'] = "User can only update their own information."
		return json.dumps(error_response), 403

	print data

	# checks if a user with specified username already exists
	username = data['username']
	existing = db.session.query(User).filter(User.username==username).first()
	if (existing):
		error_response = {}
		error_response['error'] = "Specified username is already taken."
		return json.dumps(error_response), 400

	user = db.session.query(User).filter(User.user_id==userid).first()
	user.username = username
	user.name = data['name']
	user.email = data['email']
	user.text_tag = data['textTag']
	db.session.commit()

	return user.to_json_fields_for_FE()