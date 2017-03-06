import datetime
import json

from flask import Blueprint, request
from post import Post
from user import User
from userpost import UserPost

post_api = Blueprint('post_api', __name__)

from graffiti import retrieve_user_from_request, generate_error_response, validate_text
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

@post_api.route('/post', methods=['POST'])
def create_post():
	data = request.get_json()

	# checks for necessary data params
	if ('location' not in data or 'type' not in data
			or 'latitude' not in data['location']
			or 'longitude' not in data['location']):
		return generate_error_response(ERR_400, 400)

	try:
		lon = (float)(data['location']['longitude'])
		lat = (float)(data['location']['latitude'])
	except:
		# Either the params are not there, or they are not convertable to floats
		return generate_error_response(ERR_400, 400)

	user = retrieve_user_from_request(request)
	if (user is None):
		return generate_error_response(ERR_400, 400)

	user_id = user.get_user_id()

	# create a new post and add it to the db session
	# 0 for text, 1 for image, anything else is invalid
	post_type = data['type']
	if (post_type == 0):
		text = data['text']
		if (not validate_text(text)):
			return generate_error_response(ERR_400, 400)
		# image is empty
		post = Post(text, lon, lat, user_id, 0)
		post.save_post()
	elif (post_type == 1):
		post_type = 1
		img_data = data['image']
		# empty text
		post = Post('', lon, lat, user_id, 1)
		post.save_post()
		post.upload_img_to_s3(img_data)
	else:
		return generate_error_response(ERR_400, 400)

	return post.to_json_fields_for_FE(user_id), 200

@post_api.route('/post/<int:postid>', methods=['DELETE'])
def delete_post(postid):
	# no checking of authentication is happening yet...
	post = Post.find_post(postid)

	if (post is None):
		return generate_error_response(ERR_404, 404)

	user = retrieve_user_from_request(request)
	if (user is None or post.get_poster_id() != user.get_user_id()):
		return generate_error_response(ERR_403, 403)

	jsonified_post = post.to_json_fields_for_FE(user.get_user_id())
	post.delete_post()

	return jsonified_post, 200

@post_api.route('/post/<int:postid>', methods=['GET'])
def get_post(postid):
	post = Post.find_post(postid)

	if (post is None):
		return generate_error_response(ERR_404, 404)

	user = retrieve_user_from_request(request)
	if (user is None):
		return generate_error_response(ERR_403, 403)

	return post.to_json_fields_for_FE(user.get_user_id()), 200

@post_api.route('/post', methods=['GET'])
def get_post_by_location():
	try:
		# query db for all posts in this area
		lat = (float)(request.args.get('latitude'))
		lon = (float)(request.args.get('longitude'))
	except:
		# Either the params are not there, or they are not convertable to floats
		return generate_error_response(ERR_400, 400)
	
	radius = 1 # TODO find out what number this should be
	posts = Post.find_posts_within_loc(lon, lat, radius)
	user = retrieve_user_from_request(request)
	if (user is None):
		return generate_error_response(ERR_403, 403)

	to_ret = {}
	jsonified_posts = []
	for post in posts:
		jsonified_posts.append(json.loads(post.to_json_fields_for_FE(\
			user.get_user_id())))
	to_ret['posts'] = jsonified_posts
	return json.dumps(to_ret), 200

@post_api.route('/post/coordinates', methods=['GET'])
def get_posts_coordinates():
	try:
		# query db for all posts in this area
		lat = (float)(request.args.get('latitude'))
		lon = (float)(request.args.get('longitude'))
		radius = (float)(request.args.get('radius'))
	except:
		# Either the params are not there, or they are not convertable to floats
		return generate_error_response(ERR_400, 400)

	posts = Post.find_posts_within_loc(lon, lat, radius)

	# This is commented out for now, because it from the wiki that there is no
	# authentication necessary. This can be changed easily by commenting out
	# these lines.

	# info = request.environ['META_INFO']
	# no_id = request.environ['NOID']
	# bad_token = request.environ['BADTOKEN']
	# if (info is None or no_id or bad_token):
	# 	return generate_error_response(ERR_403, 403)
	# user = User.get_user_by_google_aud(info['audCode'])

	# if (user is None):
	# 	return generate_error_response(ERR_403, 403)

	to_ret = {}
	coords = []
	for post in posts:
		coord = {}
		coord['longitude'] = post.get_longitude()
		coord['latitude'] = post.get_latitude()
		coords.append(coord)
	to_ret['coordinates'] = coords
	return json.dumps(to_ret), 200

@post_api.route('/post/<int:postid>/vote', methods=['PUT'])
def vote_post(postid):
	data = request.get_json()

	user = retrieve_user_from_request(request)
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
	userid = user.get_user_id()
	post.apply_vote(userid, postid, vote)

	return post.to_json_fields_for_FE(userid), 200
