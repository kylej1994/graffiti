import json

from flask import Blueprint, request
from post import Post
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
ERR_400_invalid = "User information is invalid."
ERR_400_taken = "Specified username is already taken."
ERR_401 = "User idToken is missing."
ERR_403_friends = "User is not friends."
ERR_403_email = "Emails are immutable."
ERR_403_update = "User can only update their own information."
ERR_403_posts = "User can only access their own information."
ERR_404 = "User not found."

def generate_error_response(message, code):
	error_response = {}
	error_response['error'] = message
	return json.dumps(error_response), code


@user_api.route('/user/login', methods=['GET'])
def user_login():
	email = request.environ['META_INFO']
	print request.environ
	if (email is None):
		return generate_error_response(ERR_401, 401);
	print email
	user = User.get_user_by_google_aud(email['audCode'])
	print user

	if (user):
		# login with idToken passed in through header
		is_new_user = False
	else:
		# create new User object with next userId and empty strings for other fields
		user = User('', email['audCode'], '', '', email['email'], '')
		user.save_user()
		is_new_user = True

	# return whether its a new user and the associated user object
	return json.dumps(dict(
		new_user=is_new_user,
		user=user.to_json_fields_for_FE())), 200

@user_api.route('/user/<int:userid>', methods=['GET'])
def get_user(userid):
	# look for user
	user = db.session.query(User).filter(User.user_id==userid).first()

	# return 404 if not found
	if (user is None):
		return generate_error_response(ERR_404, 404)

	return user.to_json_fields_for_FE(), 200

@user_api.route('/user/<int:userid>', methods=['PUT'])
def update_user(userid):
	# checks for necessary data params
	try:
		data = request.get_json()
	except:
		# if there is no data with the PUT request
		return generate_error_response(ERR_400_invalid, 400);

	if (not data or 'userid' not in data):
		return generate_error_response(ERR_400_invalid, 400);

	# TODO check id from header
	if (int(data['userid']) != userid):
		return generate_error_response(ERR_403_update, 403);

	# Call set functions and update good_inputs
	good_inputs = True

	# checks if a user with specified username already exists
	user = db.session.query(User).filter(User.user_id==userid).first()
	username = data['username']
	existing = db.session.query(User).filter(User.username==username).first()
	username_taken = False
	# If the user wants to change their username to an existing username
	if (user.get_username() != username and existing):
		username_taken = True
	else:
		good_inputs = good_inputs and user.set_username(username)

	# Not sure if all these checks are necessary?
	if (data['name'] != user.get_name()):
		good_inputs = good_inputs and user.set_name(data['name'])

	if (data['email'] != user.get_email()):
		good_inputs = good_inputs and user.set_email(data['email'])

	if (data['phone_number'] != user.get_phone_number()):
		good_inputs = good_inputs and user.set_phone_number(data['phone_number'])

	if (data['bio'] != user.get_bio()):
		good_inputs = good_inputs and user.set_bio(data['bio'])

	user.save_user()

	# Evaluate bools
	if (username_taken):
		return generate_error_response(ERR_400_taken, 400)
	if (not good_inputs):
		return generate_error_response(ERR_400_invalid, 400)

	return user.to_json_fields_for_FE(), 200

@user_api.route('/user/<int:userid>/posts', methods=['GET'])
def get_user_posts(userid):
	# look for user to make sure this user exists
	# not sure why this doesnt work...
	#user = User.find_user(userid)
	user = db.session.query(User).filter(User.user_id==userid).first()

	# return 404 if not found
	if (user is None):
		return generate_error_response(ERR_404, 404)

	# TODO check id from header

	posts = Post.find_user_posts(userid)

	to_rtn = {}
	posts_arr = []
	for post in posts:
		posts_arr.append(post.to_json_fields_for_FE())

	to_rtn['posts'] = posts_arr

	return json.dumps(to_rtn)
