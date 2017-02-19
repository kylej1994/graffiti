import datetime
import json

from flask import Blueprint, request
from post import Post
from userpost import UserPost

post_api = Blueprint('post_api', __name__)

from graffiti import db
from oauth2client import client

fake_dict = dict(
		postid=1,
		text='This one is for you, Henry ;)',
		location=dict(
			longitude=41.792279,
			latitude=-87.599954),
		created_at=datetime.datetime(1995, 05, 23, 11, 11, 11, 111).isoformat(),
		posterid=3,
		num_votes=102)
fake_response = json.dumps(fake_dict)

#string error messages
ERR_400 = "Post information was invalid."
ERR_403 = "Post is not owned by user."
ERR_403_vote = "User has already voted."
ERR_404 = "Post not found."

def validate_vote(vote):
	return vote == -1 and vote == 1

def validate_text(text):
	return len(text) <= 100

def generate_error_response(message, code):
	error_response = {}
	error_response['error'] = message
	return json.dumps(error_response), code

@post_api.route('/post', methods=['POST'])
def create_post():
	# no checking of authentication is happening yet...
	data = request.get_json()

	# checks for necessary data params
	if ('text' not in data or 'location' not in data
			or 'latitude' not in data['location']
			or 'longitude' not in data['location']):
		return generate_error_response(ERR_400, 400)

	# create a new post and add it to the db session
	text = str(data['text'])
	lon = (float)(data['location']['longitude'])
	lat = (float)(data['location']['latitude'])
	# TODO retrieve idToken to find poster_id
	# make sure this user exists
	user_id = 1

	#validates the text field for the post
	# if (self.validate_text(text) == False):
	# 	return generate_error_response(ERR_400, 400); 

	# email = request.environ['META_INFO']
	# user_id = User.get_user_id_by_google_id(email['audCode'])
	# google_aud = email['audCode']

	#validates the text field for the post
	if (not validate_text(text)):
		return generate_error_response(ERR_400, 400)

	post = Post(text, lon, lat, user_id)
	post.save_post()

	return post.to_json_fields_for_FE(), 200

@post_api.route('/post/<int:postid>', methods=['DELETE'])
def delete_post(postid):
	# no checking of authentication is happening yet...
	post = Post.find_post(postid)

	if (post is None):
		return generate_error_response(ERR_404, 404)

	# TODO check user_id
	# if (post.get_user_id() != request.get_json()['user_id']):
	# 	return generate_error_response(ERR_403, 403);

	# email = request.environ['META_INFO']
	# user_id = User.get_user_id_by_google_id(email['audCode'])
	# if (post.get_poster_id() != user_id):
	# 	return generate_error_response(ERR_403, 403)

	jsonified_post = post.to_json_fields_for_FE()
	post.delete_post()

	return jsonified_post, 200

@post_api.route('/post/<int:postid>', methods=['GET'])
def get_post(postid):
	# no checking of authentication is happening yet...

	# look for post
	# if found, retrieve it and return jsonified object with 200
	# if found but dif user, return 403
	# if not found, return 404
	post = Post.find_post(postid)
	
	if (post is None):
		return generate_error_response(ERR_404, 404)

	# email = request.environ['META_INFO']
	# user_id = User.get_user_id_by_google_id(email['audCode'])
	# if (post.get_poster_id() != user_id):
	# 	return generate_error_response(ERR_403, 403)

	return post.to_json_fields_for_FE(), 200

@post_api.route('/post', methods=['GET'])
def get_post_by_location():
	# no checking of authentication is happening yet...

	# query db for all posts in this area
	lat = (float)(request.args.get('latitude'))
	lon = (float)(request.args.get('longitude'))
	radius = 5 # TODO find out what number this should be
	posts = Post.find_posts_within_loc(lon, lat, radius)

	to_ret = {}
	jsonified_posts = []
	for post in posts:
		jsonified_posts.append(json.loads(post.to_json_fields_for_FE()))
	to_ret['posts'] = jsonified_posts
	return json.dumps(to_ret), 200

@post_api.route('/post/<int:postid>/vote', methods=['PUT'])
def vote_post(postid):
	# no checking of authentication is happening yet...

	# determine whether it is an upvote or downvote
	# look through User-Posts table to determine if the specified user has
	# already voted on this post
	# modify accordingly
	# return postid of post and new num votes

	vote = int(request.get_json()['vote'])
	post = Post.find_post(postid)

	# checks if user has already voted
	email = request.environ['META_INFO']
	user_id = User.get_user_id_by_google_id(email['audCode'])
	if (post.get_poster_id() != user_id):
		return generate_error_response(ERR_403, 403)

	post.set_vote(vote)
	return post.to_json_fields_for_FE(), 200
