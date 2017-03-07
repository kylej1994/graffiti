import json
import datetime


from flask import Blueprint, request
#from user import User

user_api = Blueprint('user_api', __name__)

user_img = open('user_img_base64.txt').read().strip()
fake_dict = dict(
	userid=1,
	username='hjylewis',
	name="Hot and Bothered",
	email="comeNfind@me.com",
	bio="Yum yum yum!",
	phone_number="1234567890",
	img_tag=user_img
)
fake_response = json.dumps(fake_dict)

fake_post_dict = dict(
	postid=1,
	text='This one is for you, Henry ;)',
	location=dict(
		longitude=41.792279,
		latitude=-87.599954),
	created_at=datetime.datetime(1995, 05, 23, 11, 11, 11, 111).isoformat(),
	posterid=3,
	num_votes=102
)

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

@user_api.route('/user/<int:userid>/posts', methods=['GET'])
def get_user_posts(userid):

	return json.dumps(dict(
			posts=[fake_post_dict, fake_post_dict, fake_post_dict, fake_post_dict, fake_post_dict,
					fake_post_dict, fake_post_dict, fake_post_dict, fake_post_dict, fake_post_dict]
		))
