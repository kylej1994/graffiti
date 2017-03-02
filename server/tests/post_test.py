import os
import json
import sys
import unittest
import tempfile
import base64

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti, user, post
from graffiti.user import User
from graffiti.post import Post
from graffiti.userpost import UserPost
from graffiti.graffiti import db

from datetime import datetime, date
import time

# note: poster_id aka user_id will always be 1
poster_id = 1
poster_id2 = 2

class PostTestCase(unittest.TestCase):

    def setUp(self):
        self.db_fd, graffiti.app.config['DATABASE'] = tempfile.mkstemp()
        graffiti.app.config['TESTING'] = True
        with graffiti.app.app_context():
            # initializes and fills the database that is used
            graffiti.init_db()
            graffiti.fill_db()

    def tearDown(self):
        os.close(self.db_fd)
        os.unlink(graffiti.app.config['DATABASE'])
        with graffiti.app.app_context():
            # clears the database that is used
            graffiti.clear_db_of_everything()

    # tests that the poster id (user_id) of the post is being set correctly
    def test_get_poster_id(self):
        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()
        self.assertTrue(post.get_poster_id() == poster_id)
        self.assertFalse(post.get_poster_id() == 100)

    # tests that all posts of a user are being retrieved appropriately
    def test_find_user_posts(self):
        posts = Post.find_user_posts(poster_id)
        self.assertTrue(len(posts) == 4)

    # tests that a post is being stored into the database correctly
    def test_save_post(self):
        post = Post('to_save', 123, 123, poster_id)
        post.save_post()
        self.assertTrue(len(Post.find_user_posts(poster_id)) == 5)

    def test_find_post(self):
        post = Post.find_post(poster_id)
        self.assertIsNotNone(post)
        self.assertTrue(post.get_poster_id() == poster_id)
        self.assertTrue(post.get_text() == 'text')

    def test_set_vote(self):
        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()
        post_id = post.post_id
        self.assertTrue(post.num_votes == 0)
        post.set_vote(2)
        self.assertTrue(db.session.query(Post).filter(Post.post_id==post_id).first().num_votes == 2)

    def test_increment_vote(self):
        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()
        post_id = post.post_id
        self.assertTrue(post.num_votes == 0)
        post.increment_vote(1)
        post.increment_vote(1)
        post.increment_vote(1)
        self.assertTrue(db.session.query(Post).filter(Post.post_id==post_id).first().num_votes == 3)

    def test_apply_vote(self):
        db.session.add(User('katlu', \
        "1208719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com", \
        '6465263918', \
        'Ron Yehoshua', \
        'kyle@jablonk.net', \
        'Yeah'))
        poster_id2 = 2

        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()
        post_id = post.post_id
        # Upvote
        self.assertTrue(Post.apply_vote(poster_id, post_id, 1))
        self.assertTrue(db.session.query(Post).filter(Post.post_id==post_id).first().num_votes == 1)
        self.assertTrue(db.session.query(UserPost).filter(UserPost.user_id==poster_id)\
            .filter(UserPost.post_id==post_id).first().vote == 1)
        # Downvote
        self.assertTrue(Post.apply_vote(poster_id, post_id, -1))
        self.assertTrue(db.session.query(Post).filter(Post.post_id==post_id).first().num_votes == -1)
        self.assertTrue(db.session.query(UserPost).filter(UserPost.user_id==poster_id)\
            .filter(UserPost.post_id==post_id).first().vote == -1)
        # New user, vote positive value
        self.assertTrue(Post.apply_vote(poster_id2, post_id, 3))
        self.assertTrue(db.session.query(Post).filter(Post.post_id==post_id).first().num_votes == 0)
        self.assertTrue(db.session.query(UserPost).filter(UserPost.user_id==poster_id2)\
            .filter(UserPost.post_id==post_id).first().vote == 1)
        # First user change vote, neutral
        self.assertTrue(Post.apply_vote(poster_id, post_id, 0))
        self.assertTrue(db.session.query(Post).filter(Post.post_id==post_id).first().num_votes == 1)
        self.assertTrue(db.session.query(UserPost).filter(UserPost.user_id==poster_id)\
            .filter(UserPost.post_id==post_id).first().vote == 0)

    def test_get_text(self):
        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()
        text = post.get_text()
        self.assertIsNotNone(text)
        self.assertTrue(text == "text")
        self.assertFalse(text == "username")

    def test_find_posts_within_loc(self):
        # set up for testing locations
        graffiti.clear_db_of_everything()
        graffiti.init_db()

        # user must exist in db before posts
        db.session.add(User('easmith', \
        "1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com", \
        '9172825753', \
        'Emma Smith', \
        'kat@lu.com', \
        'My name is jablonk'))
        db.session.commit()

        longitude = 51.5192028
        latitude = -0.140863
        hackney_longitude = 51.5457865
        hackney_latitude = -0.0554184
        aus_longitude = -37.8167
        aus_latitude = 144.9667

        to_add3 = Post('in london', 51.5192028, -0.140863, 1)
        to_add = Post('in australia', -37.8167, 144.9667, 1)
        to_add2 = Post('in hackney', 51.5457865, -0.0554184, 1)
        to_add3.save_post()
        to_add.save_post()
        to_add2.save_post()

        distance1 = 1
        distance2 = 10000
        distance3 = 16900 * 1000

        ### begin tests
        #gets all post within distance 1 
        posts = Post.find_posts_within_loc(longitude, latitude, distance1)
        self.assertTrue(posts[0].longitude == longitude)
        self.assertTrue(posts[0].latitude == latitude)

        #gets all two posts within distance 2, should get 2 posts in the UK
        posts = Post.find_posts_within_loc(longitude, latitude, distance2)
        self.assertTrue(posts[0].longitude == longitude)
        self.assertTrue(posts[0].latitude == latitude)
        self.assertTrue(posts[1].longitude == hackney_longitude)
        self.assertTrue(posts[1].latitude == hackney_latitude)
   		
   		#gets all three posts within distance 3
        posts = Post.find_posts_within_loc(longitude, latitude, distance3)
        self.assertTrue(posts[0].longitude == longitude)
        self.assertTrue(posts[0].latitude == latitude)
        self.assertTrue(posts[2].longitude == hackney_longitude)
        self.assertTrue(posts[2].latitude == hackney_latitude)
        self.assertTrue(posts[1].longitude == aus_longitude)
        self.assertTrue(posts[1].latitude == aus_latitude)


    def test_delete_post(self):
        to_delete = Post("text2", 51.5192024, -0.140862, poster_id)
        db.session.add(to_delete)
        db.session.commit()
        post_id = to_delete.post_id
        to_delete.delete_post()
        self.assertIsNone(db.session.query(Post).filter(Post.post_id==post_id).first())

    # iteration 2 tests
    # tests that the stored image location matches the image associated w post
    def test_get_img_file_loc(self):
        #Be sure to concat out the join time, since that's impossible to measure
        img_url = 'https://s3.amazonaws.com/graffiti-post-images/postid:6&created_at:1488448033'
        img_url_concat = img_url.split('&')[0]

        with open('cat-pic.png', 'rb') as imageFile:
            img_str = base64.b64encode(imageFile.read())


        post = Post('to_save', 123, 123, poster_id)
        post.save_post()
        post.upload_img_to_s3(img_str)
        print post.get_img_file_loc()#.split('&')[0]
        self.assertTrue(post.get_img_file_loc().split('&')[0] == img_url_concat)

    def test_get_img_file(self):
        print 'this is the get_img_file test'
        with open('cat-pic.png', 'rb') as imageFile:
            img_str = base64.b64encode(imageFile.read())

        post = Post('to_save', 123, 123, poster_id)
        post.save_post()
        post.upload_img_to_s3(img_str)
        self.assertTrue(post.get_img_file() == img_str)


if __name__ == '__main__':
    unittest.main()
