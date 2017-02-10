import json

from flask import Flask, request

app = Flask(__name__)

def init_db():
    """ Initializes the database. """
    pass

@app.route('/posts/create', methods=['POST'])
def create_post():
    return json.dumps({'lat': 'post created'})
