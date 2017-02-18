import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti, post, user
from graffiti.user import User
from graffiti.graffiti import db

from datetime import datetime, date
import time

class PostTestCase():

    user1 = User("username", 
            "1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
            "9172825753", "name", "email", "bio")

    def setUp(self):
        self.db_fd, graffiti.app.config['DATABASE'] = tempfile.mkstemp()
        graffiti.app.config['TESTING'] = True

        self.app = graffiti.app.test_client()
        db.create_all()
        db.session.add(Post("text", 51.5192028, -0.140863, user1.get_user_id()))
        db.session.flush()

        with graffiti.app.app_context():
            # initializes the database that is used
            graffiti.init_db()

    def tearDown(self):
        super(APITestCase, self).tearDown()
        db.session.remove()
        db.drop_all()

    # tests that the poster id (user_id) of the post is being set correctly
    def test_get_poster_id(self):
        post = db.query(Post).filter(Post.poster_username=="username").first()
        assert (post.get_poster_id() == user1.get_user_id())
        assert (post.get_poster_id() != user1.get_user_id() + 1)

    def test_set_votes(self):
        post = db.query(Post).filter(Post.poster_username=="username").first()
        self.assertTrue(post.num_votes == 0)
        post.set_votes(1)
        self.assertTrue(db.query(Post).filter(Post.poster_username=="username").first().num_votes == 1)
        post.set_votes(-1)
        self.assertTrue(db.query(Post).filter(Post.poster_username=="username").first().num_votes == 0)

    def test_get_created_at(self):
        before = time.time()
        new_post = Post("text2", 51.5192028, -0.140863, user1.get_user_id())
        db.session.add(new_post)
        db.session.flush()
        after = time.time()
        middle = time.mktime(db.query(Post).filter(Post.poster_username=="username").first().created_at.timetuple())
        assertTrue(before <= middle <= after)

    def test_get_text(self):
        post = db.query(Post).filter(Post.poster_username=="username").first()
        text = post.get_text()
        self.assertIsNotNone(text)
        self.assertTrue(text == "text")
        self.assertFalse(text == "username")

    def test_delete_post(self):
        post = db.query(Post).filter(Post.poster_username=="username").first()
        post.delete_post()
        assertIsNone(db.query(Post).filter(Post.poster_username=="username").first())

    def test_find_posts_within_loc(self):
        longitude = 51.5192028
        latitude = -0.140863
        hackney_longitude = 51.5457865
        hackney_latitude = -0.0554184
        aus_longitude = -37.8167
        aus_langititude = 144.9667

        to_add = Post("in australia", -37.8167, 144.9667, user1.get_user_id())
        to_add2 = Post("in hackney", 51.5457865, -0.0554184, user1.get_user_id())
        to_add.save_post()
        to_add2.save_post()

        distance1 = 1
        distance2 = 10000
        distance3 = 16900 * 1000

        post = db.query(Post).filter(Post.poster_username=="username").first()

        #gets all post within distance 1 
        posts = Post.find_posts_within_loc(longitutde, latittude, distance1)
        assertTrue(posts.size() == 1)
        assertTrue(posts[0].longitude == post.longitude)
        assertTrue(posts[0].latitude == post.latitude)

        #gets all two posts within distance 2, should get 2 posts in the UK
        posts = Post.find_posts_within_loc(longitutde, latittude, distance2)
        assertTrue(posts.size() == 2)
        assertTrue(posts[0].longitude == longitude)
        assertTrue(posts[0].latitude == latitude)
        assertTrue(posts[1].longitude == hackney_longitude)
        assertTrue(posts[1].latitude == hackney_latitude)
   		
   		#gets all three posts within distance 3
        posts = Post.find_posts_within_loc(longitutde, latittude, distance3)
        assertTrue(posts.size() == 3)
        assertTrue(posts[0].longitude == longitude)
        assertTrue(posts[0].latitude == latitude)
        assertTrue(posts[1].longitude == hackney_longitude)
        assertTrue(posts[1].latitude == hackney_latitude)
        assertTrue(posts[2].longitude == aus_longitude)
        assertTrue(posts[2].latitude == aus_latitude)




if __name__ == '__main__':
    unittest.main()
