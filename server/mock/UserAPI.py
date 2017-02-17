import json

from flask import Blueprint, request
#from user import User

user_api = Blueprint('user_api', __name__)

fake_dict = dict(
	userid=1,
	username='hylewis',
	name="Hot and Bothered",
	email="comeNfind@me.com",
	bio="Yum yum yum!"
)
fake_response = json.dumps(fake_dict)

@user_api.route('/user/login', methods=['GET'])
def user_login():
	# no checking of authentication is happening yet...
	print 'in create user'

	# if this user is a new user
	# create new User object with next userId and empty strings for other fields
	# else, login with idToken passed in through header
	# return whether its a new user and the associated user object

	return json.dumps(dict(
		new_user=False,
		user=fake_dict))

@user_api.route('/user/<int:userid>', methods=['GET'])
def get_user(userid):
	# no checking of authentication is happening yet...

	# look for user based on userid
	# return user object if found
	# return 404 otherwise

	return fake_response

@user_api.route('/user/<int:userid>', methods=['PUT'])
def update_user(userid):
	# no checking of authentication is happening yet...

	data = request.get_json()

	# checks for necessary data params
	if ('userid' not in data or data['userid'] != userid):
		error_response = {}
		error_response['error'] = "User can only update their own information."
		return json.dumps(error_response), 403

	# look for user based on userId
	# update and return user object if found
	# return 404 otherwise

	return fake_response
