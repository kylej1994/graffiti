import json

from flask import Blueprint, request
#from post import Post

post_api = Blueprint('post_api', __name__)


@post_api.route('/post', methods=['POST'])
def create_post():
	# no checking of authentication is happening yet...
	print 'in create post'
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

	# would create a new post and add it to the db session here

	return 'hi post\n'

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

	return 'got post\n'

@post_api.route('/post/<float:longitude><float:latitude>', methods=['GET'])
def get_post_by_locatoin(longitude, latitude):
	# no checking of authentication is happening yet...

	# query db for all posts in this area

	return 'got posts\n'

@post_api.route('/post/<int:postid>', methods=['PUT'])
def vote_post(postid):
	# no checking of authentication is happening yet...

	# determine whether it is an upvote or downvote
	# look through User-Posts table to determine if the specified user has
	# already voted on this post
	# modify accordingly
	# return postid of post and new num votes

	return 'voted on post\n'
