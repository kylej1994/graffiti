import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti
from graffiti.user import User
from graffiti.post import Post
from graffiti.graffiti import db

from datetime import datetime, date
import time

user1 = User("username", 
            "1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
            "9172825753", "name", "email", "bio")
test_post = Post("text", 51.5192028, -0.140863, user1.get_user_id())
poster_id = test_post.get_poster_id()

class PostTestCase(APITestCase):

    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()
        db.session.add(test_post)
        db.session.commit()

    def tearDown(self):
        db.session.remove()
        db.drop_all()

    # tests that the poster id (user_id) of the post is being set correctly
    def test_get_poster_id(self):
        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()
        self.assertTrue(post.get_poster_id() == poster_id)
        self.assertFalse(post.get_poster_id() == poster_id + 100)

    def test_set_votes(self):
        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()
        self.assertTrue(post.num_votes == 0)
        post.set_votes(1)
        self.assertTrue(db.session.query(Post).filter(Post.poster_id==poster_id).first().num_votes == 1)
        post.set_votes(-1)
        self.assertTrue(db.session.query(Post).filter(Post.poster_id==poster_id).first().num_votes == 0)

    def test_get_created_at(self):
        before = time.time()
        new_post = Post("text2", 51.5192028, -0.140863, user1.get_user_id())
        db.session.add(new_post)
        db.session.commit()
        after = time.time()
        middle = time.mktime(db.session.query(Post).filter(Post.poster_id==poster_id).first().created_at.timetuple())
        self.assertTrue(before <= middle <= after)

    def test_get_text(self):
        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()
        text = post.get_text()
        self.assertIsNotNone(text)
        self.assertTrue(text == "text")
        self.assertFalse(text == "username")

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

        post = db.session.query(Post).filter(Post.poster_id==poster_id).first()

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


    def test_delete_post(self):
        to_delete = Post("text2", 51.5192024, -0.140862, user1.get_user_id())
        db.session.add(to_delete)
        db.session.commit()
        post_id = to_delete.post_id
        to_delete.delete_post()
        self.assertIsNone(db.session.query(Post).filter(Post.post_id==post_id).first())

if __name__ == '__main__':
    unittest.main()
