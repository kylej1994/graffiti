import json
import pgdb

from flask import Flask, request
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config.from_pyfile('graffiti.cfg')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

@app.route('/initdb')
def init_db():
	db.drop_all()
	db.create_all()

	return 'initted\n'

print init_db()

# These imports must happen after the initialization of the db because these
# objects import db in their respective files.
from post import Post
from user import User

from UserAPI import user_api
from PostAPI import post_api

app.register_blueprint(user_api)
app.register_blueprint(post_api)

# FOR TESTING PURPOSES ONLY
@app.route('/filldb')
def fill_db():
	# Sample values
	db.create_all()
	db.session.add(Post("text", 51.5192028, -0.140863, "easmith"))
	db.session.add(User("easmith", \
		"1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com", \
		"9172825753", \
		'Emma Smith', \
		'kat@lu.com', \
		'My name is jablonk'))
	db.session.commit()
	return 'added\n'

# FOR TESTING PURPOSES ONLY
@app.route('/cleardb')
def clear_db_of_everything():
	db.drop_all()
	return 'dropped\n'

@app.route('/')
def hello():
	return 'hello\n'