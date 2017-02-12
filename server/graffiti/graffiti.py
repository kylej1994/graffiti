import json

from flask import Flask, request

app = Flask(__name__)

from UserAPI import user_api
from PostAPI import post_api

app.register_blueprint(user_api)
app.register_blueprint(post_api)

def init_db():
    """ Initializes the database. """
    # halp lol
    pass

@app.route('/')
def hello():
    return 'Hello World!\n'