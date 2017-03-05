import json

from flask import Blueprint, request
from post import Post
from user import User

user_api = Blueprint('user_api', __name__)

from graffiti import retrieve_user_from_request

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
	user = retrieve_user_from_request(request)
	if (user):
		# login with idToken passed in through header
		is_new_user = False
	else:
		# create new User object with next userId and empty strings for other
		# fields. Also checks for necessary parameters to make a new user
		info = request.environ['META_INFO']
		if ('audCode' in info and 'email' in info):
			user = User('', info['audCode'], '', '', info['email'], '')
		else:
			return generate_error_response(ERR_401, 401)
		user.save_user()
		is_new_user = True

	# return whether its a new user and the associated user object
	return json.dumps(dict(
		new_user=is_new_user,
		user=json.loads(user.to_json_fields_for_FE()))), 200

@user_api.route('/user/<int:userid>', methods=['GET'])
def get_user(userid):
	# look for user
	user = User.find_user_by_id(userid)

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
		return generate_error_response(ERR_400_invalid, 400)

	if (not data or 'userid' not in data):
		return generate_error_response(ERR_400_invalid, 400)

	user = retrieve_user_from_request(request)
	if (user is None):
		return generate_error_response(ERR_404, 404)

	if (int(data['userid']) != userid and user.get_user_id() != userid):
		return generate_error_response(ERR_403_update, 403)

	# Call set functions and update good_inputs
	good_inputs = True

	# checks if a user with specified username already exists
	username = data['username']
	existing = User.find_user_by_username(username)
	username_taken = False
	# If the user wants to change their username to an existing username
	if (user.get_username() != username and existing):
		username_taken = True
	else:
		good_inputs = good_inputs and user.set_username(username)

	# Not sure if all these checks are necessary?
	if ('name' in data and data['name'] != user.get_name()):
		good_inputs = good_inputs and user.set_name(data['name'])

	if ('phone_number' in data and \
		 data['phone_number'] != user.get_phone_number()):
		good_inputs = good_inputs and user.set_phone_number(data['phone_number'])

	if ('bio' in data and data['bio'] != user.get_bio()):
		good_inputs = good_inputs and user.set_bio(data['bio'])

	# save user before check email because even if user wants to change email,
	# the other fields should still be modified.
	user.save_user()

	if ('img_tag' in data):
		good_inputs = good_inputs and user.set_image_tag(data['img_tag'])

	if ('email' in data and data['email'] != user.get_email()):
		return generate_error_response(ERR_403_email, 403)

	# Evaluate bools
	if (username_taken):
		return generate_error_response(ERR_400_taken, 400)
	if (not good_inputs):
		return generate_error_response(ERR_400_invalid, 400)

	return user.to_json_fields_for_FE(), 200

@user_api.route('/user/<int:userid>/posts', methods=['GET'])
def get_user_posts(userid):
	# look for user to make sure this user exists
	user = User.find_user_by_id(userid)

	# return 404 if not found
	if (user is None):
		return generate_error_response(ERR_404, 404)

	info = request.environ['META_INFO']
	no_id = request.environ['NOID']
	bad_token = request.environ['BADTOKEN']
	if (info is None or no_id or bad_token
			or user.get_google_aud() != info['audCode']):
		return generate_error_response(ERR_403_posts, 403)

	posts = Post.find_user_posts(userid)

	to_rtn = {}
	posts_arr = []
	for post in posts:
		posts_arr.append(json.loads(post.to_json_fields_for_FE(\
			user.get_user_id())))

	to_rtn['posts'] = posts_arr

	return json.dumps(to_rtn)
