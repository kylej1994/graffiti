import datetime
import json

from flask import Blueprint, request
from post import Post
from user import User
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
ERR_403_vote = "Post cannot be voted on by user."
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

	info = request.environ['META_INFO']
	no_id = request.environ['NOID']
	bad_token = request.environ['BADTOKEN']
	if (info is None or no_id or bad_token):
		return generate_error_response(ERR_400, 400)
	user = User.get_user_by_google_aud(info['audCode'])

	if (user is None or not validate_text(text)):
		return generate_error_response(ERR_400, 400)

	user_id = user.get_user_id()
	post = Post(text, lon, lat, user_id)
	post.save_post()

	return post.to_json_fields_for_FE(user_id), 200

@post_api.route('/post/<int:postid>', methods=['DELETE'])
def delete_post(postid):
	# no checking of authentication is happening yet...
	post = Post.find_post(postid)

	if (post is None):
		return generate_error_response(ERR_404, 404)

	info = request.environ['META_INFO']
	no_id = request.environ['NOID']
	bad_token = request.environ['BADTOKEN']
	if (info is None or no_id or bad_token):
		return generate_error_response(ERR_403, 403)
	user = User.get_user_by_google_aud(info['audCode'])

	if (user is None or post.get_user_id() != user.get_user_id()):
		return generate_error_response(ERR_403, 403)

	jsonified_post = post.to_json_fields_for_FE(user.get_user_id())
	post.delete_post()

	return jsonified_post, 200

@post_api.route('/post/<int:postid>', methods=['GET'])
def get_post(postid):
	post = Post.find_post(postid)
	
	if (post is None):
		return generate_error_response(ERR_404, 404)

	info = request.environ['META_INFO']
	no_id = request.environ['NOID']
	bad_token = request.environ['BADTOKEN']
	if (info is None or no_id or bad_token):
		return generate_error_response(ERR_403, 403)
	user = User.get_user_by_google_aud(info['audCode'])

	if (user is None):
		return generate_error_response(ERR_403, 403)

	return post.to_json_fields_for_FE(user.get_user_id()), 200

@post_api.route('/post', methods=['GET'])
def get_post_by_location():
	# no checking of authentication is happening yet...

	# query db for all posts in this area
	lat = (float)(request.args.get('latitude'))
	lon = (float)(request.args.get('longitude'))
	radius = 5 # TODO find out what number this should be
	posts = Post.find_posts_within_loc(lon, lat, radius)

	info = request.environ['META_INFO']
	no_id = request.environ['NOID']
	bad_token = request.environ['BADTOKEN']
	if (info is None or no_id or bad_token):
		return generate_error_response(ERR_403, 403)
	user = User.get_user_by_google_aud(info['audCode'])

	if (user is None):
		return generate_error_response(ERR_403, 403)

	to_ret = {}
	jsonified_posts = []
	for post in posts:
		jsonified_posts.append(json.loads(post.to_json_fields_for_FE(\
			user.get_user_id())))
	to_ret['posts'] = jsonified_posts
	return json.dumps(to_ret), 200

@post_api.route('/post/<int:postid>/vote', methods=['PUT'])
def vote_post(postid):
	data = request.get_json()
	info = request.environ['META_INFO']
	print info
	no_id = request.environ['NOID']
	bad_token = request.environ['BADTOKEN']
	if (info is None or no_id or bad_token):
		return generate_error_response(ERR_403_vote, 403)
	print info['audCode']
	user = User.get_user_by_google_aud(info['audCode'])
	print user

	if (user is None):
		return generate_error_response(ERR_403_vote, 403)

	# checks for necessary data params
	if ('vote' not in data):
		return generate_error_response(ERR_400, 400)

	# create a new post and add it to the db session
	vote = int(data['vote'])

	# find the post to vote on
	post = Post.find_post(postid)

	if (post is None):
		return generate_error_response(ERR_404, 404)

	# Call apply_vote
	post.apply_vote(user.get_user_id(), postid, vote)

	return post.to_json_fields_for_FE(user.get_user_id()), 200
