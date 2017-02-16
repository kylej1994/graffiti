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

#string error messages
ERR_400_invalid = "User information is invalid"
ERR_400_taken = "Specified username is already taken."
ERR_401 = "User idToken is missing."
ERR_403_friends = "User is not friends."
ERR_403_email = "Emails are immutable."
ERR_403_update = "User can only update their own information."
ERR_404 = "User not found."

def generate_error_response(message, code):
	error_response = {}
	error_response['error'] = message
	return json.dumps(error_response), code


@user_api.route('/user/login', methods=['GET'])
def user_login():	
	id_token = #TODO
	if (id_token == None):
			return generate_error_response(ERR_401, 401);

	# Find user via id_token

	if (user):		
		# login with idToken passed in through header
		# TODO
		is_new_user = 'No'
	else:
		# create new User object with next userId and empty strings for other fields
		user = User("", google_aud, "", "", "", "")
		user.save_user()
		is_new_user = 'Yes'
	
	# return whether its a new user and the associated user object
	return json.dumps(dict(
		new_user=is_new_user,
		user=user)), 200

@user_api.route('/user/<int:userid>', methods=['GET'])
def get_user(userid):
	# Look for user based on userid 
	data = request.get_json()
	if ('userid' not in data):
		return generate_error_response(ERR_400_invalid, 400);

	# make sure both userid values are the same
	if (int(data['userid']) != userid):
		return generate_error_response(ERR_403_update, 403);

	# return user object if found
	user = db.session.query(User).filter(User.user_id==userid).first()
	if (user != None):
		return user.to_json_fields_for_FE(), 200

	# return 404 otherwise
	return generate_error_response(ERR_404, 404)

@user_api.route('/user/<int:userid>', methods=['PUT'])
def update_user(userid):
	# checks for necessary data params
	data = request.get_json()
	if ('userid' not in data):
		return generate_error_response(ERR_400_invalid, 400);
	
	if (int(data['userid']) != userid):
		return generate_error_response(ERR_403_update, 403);

	# checks if a user with specified username already exists
	user = db.session.query(User).filter(User.user_id==userid).first()
	
	username = data['username']
	existing = db.session.query(User).filter(User.username==username).first()
	username_taken = False
	if (existing):
		username_taken = True
	else:
		user.set_username(username)

	# Call set functions and update rtn_val
	rtn_val = True
	if (data['name'] != user.get_name()):
		rtn_val = rtn_val && user.set_name(data['name'])

	if (data['email'] != user.get_email()):
		rtn_val = rtn_val && user.set_email(data['email'])

	# TODO add phone number?

	# TODO texttag or bio?
	if (data['bio'] != user.get_bio()):
		rtn_val = rtn_val && user.set_bio(data['bio'])

	# Evaluate bools
	if (username_taken):
		generate_error_response(ERR_400_taken, 400)
	if (rtn_val == False):
		generate_error_response(ERR_400_invalid, 400)

	user.save_user()
	return user.to_json_fields_for_FE(), 200
