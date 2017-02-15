import datetime
import json

from flask import Blueprint, request
from post import Post

post_api = Blueprint('post_api', __name__)

from graffiti import db

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

@post_api.route('/post', methods=['POST'])
def create_post():
	# no checking of authentication is happening yet...
	data = request.get_json()

	# checks for necessary data params
	if ('text' not in data or 'location' not in data
			or 'latitude' not in data['location']
			or 'longitude' not in data['location']):
		error_response = {}
		error_response['error'] = "Post information was invalid."
		return json.dumps(error_response), 400

	# not exactly sure what the db setup will look like for now but I have a
	# rough idea based on this SO question: http://stackoverflow.com/questions/13058800/using-flask-sqlalchemy-in-blueprint-models-without-reference-to-the-app?rq=1
	# and the example flask app with PostGIS github repo here: https://github.com/ryanj/flask-postGIS

	# create a new post and add it to the db session
	text = data['text']
	lon = data['location']['longitude']
	lat = data['location']['latitude']
	user_id = data['user_id'] #ask KYLE
	google_aud = data['google_aud']
	post = Post(text, lon, lat, user_id, google_aud)
	post.save_post()

	return post.to_json_fields_for_FE(), 200

@post_api.route('/post/<int:postid>', methods=['DELETE'])
def delete_post(postid):
	# no checking of authentication is happening yet...

	# look for post
	# if found, delete it and return success (200)
	# if found but dif user, return 403
	# if not found, return 404
	post = Post.find_post(postid)

	if (post is None):
		error_response = {}
		error_response['error'] = "Post not found."
		return json.dumps(error_response), 404

	if (post.get_user_id() != request.get_json()['user_id']):
		error_response = {}
		error_response['error'] = "Post is not owned by user."
		return json.dumps(error_response), 403

	post.delete_post()

	return 200

@post_api.route('/post/<int:postid>', methods=['GET'])
def get_post(postid):
	# no checking of authentication is happening yet...

	# look for post
	# if found, retrieve it and return jsonified object with 200
	# if found but dif user, return 403
	# if not found, return 404

	post = Post.find_post(postid)
	
	if (post is None):
		error_response = {}
		error_response['error'] = "Post not found."
		return json.dumps(error_response), 404

	if (post.get_user_id() != request.get_json()['user_id']):
		error_response = {}
		error_response['error'] = "Post is not owned by user."
		return json.dumps(error_response), 403

	return post.to_json_fields_for_FE(), 200

@post_api.route('/post', methods=['GET'])
def get_post_by_location():
	# no checking of authentication is happening yet...

	# query db for all posts in this area
	lat = request.args.get('latitude')
	lon = request.args.get('longitude')
	radius = 5 #to be changed later
	posts = Post.find_post_within_loc(lon, lat, radius)

	#TODO format for returning multiple posts?
	to_ret = []
	for post in posts:
		to_ret += post.to_json_fields_for_FE()

	return to_ret

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
	# TODO need to check if user has already voted
	post.apply_vote(vote)

	return post.to_json_fields_for_FE(), 200
