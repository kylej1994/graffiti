import random
import time
import json

from flask import Blueprint, request
#from post import Post

post_api = Blueprint('post_api', __name__)

user_img = open('user_img_base64.txt').read().strip()
fake_user = dict(
	userid=1,
	username='hothjylewis',
	name="Hot and Bothered",
	email="comeNfind@me.com",
	bio="Yum yum yum!",
	phone_number="1234567890",
	img_tag=user_img
)

fake_post = dict(
		postid=1,
		type=0,
		text='This one is for you, Henry ;)',
		location=dict(
			longitude=41.792279,
			latitude=-87.599954),
		created_at=time.time(),
		poster=fake_user,
		current_user_vote=1,
		num_votes=102)


post_img = open('post_img_base64.txt').read().strip()
fake_img_post = dict(
		postid=1,
		type=1,
		image=post_img,
		location=dict(
			longitude=41.792279,
			latitude=-87.599954),
		created_at=time.time(),
		poster=fake_user,
		current_user_vote=1,
		num_votes=102)

fake_response = json.dumps(fake_post)

@post_api.route('/post', methods=['POST'])
def create_post():
	# no checking of authentication is happening yet...
	print 'in create post'


	""" Commented this out so that frontend can do stuff with the api before
	it was completely implemented. """
	# data = request.get_json()

	# # checks for necessary data params
	# if ('text' not in data or 'location' not in data
	# 		or 'latitude' not in data['location']
	# 		or 'longitude' not in data['location']):
	# 	error_response = {}
	# 	error_response['error'] = "Post information was invalid."
	# 	return json.dumps(error_response), 400

	# not exactly sure what the db setup will look like for now but I have a
	# rough idea based on this SO question: http://stackoverflow.com/questions/13058800/using-flask-sqlalchemy-in-blueprint-models-without-reference-to-the-app?rq=1
	# and the example flask app with PostGIS github repo here: https://github.com/ryanj/flask-postGIS

	# would create a new post and add it to the db session here

	return fake_response

@post_api.route('/post/<int:postid>', methods=['DELETE'])
def delete_post(postid):
	# no checking of authentication is happening yet...

	# look for post
	# if found, delete it and return success (200)
	# if found but dif user, return 403
	# if not found, return 404

	return 'deleted post\n'

@post_api.route('/post/<int:postid>', methods=['GET'])
def get_post(postid):
	# no checking of authentication is happening yet...

	# look for post
	# if found, retrieve it and return jsonified object with 200
	# if found but dif user, return 403
	# if not found, return 404

	return fake_response

@post_api.route('/post', methods=['GET'])
def get_post_by_location():
	# no checking of authentication is happening yet...

	# query db for all posts in this area
	lat = request.args.get('latitude')
	lon = request.args.get('longitude')
	posts = []
	for _ in range(10):
		if random.choice([True, False]):
			posts.append(fake_img_post)
		else:
			posts.append(fake_post)

	return json.dumps(dict(
		posts=posts
	))

@post_api.route('/post/<int:postid>/vote', methods=['PUT'])
def vote_post(postid):
	# no checking of authentication is happening yet...

	# determine whether it is an upvote or downvote
	# look through User-Posts table to determine if the specified user has
	# already voted on this post
	# modify accordingly
	# return postid of post and new num votes

	return fake_response
