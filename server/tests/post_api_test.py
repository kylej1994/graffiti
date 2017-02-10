import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti, db
from graffiti.models import Post #this doesnt exist yet

import geoalchemy
from geoalchemy.postgis import PGComparator

class PostTestCase(APITestCase):

    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()
        db.create_all()
        db.session.add(Post("text", 51.5192028, -0.140863, "username"))
        db.session.flush()

    def tearDown(self):
        super(APITestCase, self).tearDown()
        db.session.remove()
        db.drop_all()

   	def test_increment_votes(self):
   		post = db.query(Post).filter(Post.poster_username=="username").first()
        self.assertTrue(post.num_votes == 0)
        post.increment_votes()
        self.assertTrue(db.query(Post).filter(Post.poster_username=="username").first().num_votes == 1)
        post.increment_votes()
        self.assertTrue(db.query(Post).filter(Post.poster_username=="username").first().num_votes == 2)

    def test_decrement_votes(self):
    	post = db.query(Post).filter(Post.poster_username=="username").first()
        post.increment_votes()
        post.increment_votes()
        post.decrement_votes()
        self.assertTrue(db.query(Post).filter(Post.poster_username=="username").first().num_votes == 1)
        post.decrement_votes()
        self.assertTrue(db.query(Post).filter(Post.poster_username=="username").first().num_votes == 0)
        post.decrement_votes()
        self.assertTrue(db.query(Post).filter(Post.poster_username=="username").first().num_votes == -1)

    def test_get_text(self):
    	post = db.query(Post).filter(Post.poster_username=="username").first()
    	text = post.get_text()
    	self.assertIsNotNone(text)
        self.assertTrue(text == "text")
        self.assertFalse(text == "username")

    def test_get_poster_username(self):
    	post = db.query(Post).filter(Post.poster_username=="username").first()
    	username = post.test_get_poster_username()
    	self.assertIsNotNone(username)
    	self.assertTrue(username == "username")
    	self.assertFalse(username == "text")

    #change the function def of delete_post() to return bool
   	def test_delete_post(self):
   		post2 = Post("text2", -37.8167, 144.9667, "username2")
   		assertFalse(post2.delete_post())
   		post = db.query(Post).filter(Post.poster_username=="username").first()
   		assertTrue(post.delete_post())
   		assertIsNone(db.query(Post).filter(Post.poster_username=="username").first())


   	def test_get_nearby_posts(self):
   		longitude = 51.5192028
   		latitude = -0.140863
   		hackney_longitude = 51.5457865
   		hackney_latitude = -0.0554184
   		aus_longitude = -37.8167
   		aus_langititude = 144.9667

   		db.session.add(Post("in australia", -37.8167, 144.9667, "username2"))
   		db.session.add(Post("in hackney", 51.5457865, -0.0554184, "username2"))

   		distance1 = 1
   		distance2 = 10000
   		distance3 = 16900 * 1000

   		post = db.query(Post).filter(Post.poster_username=="username").first()

   		#gets all post within distance 1 
   		posts = post.get_nearby_posts(distance1)
   		assertTrue(posts.size() == 1)
   		assertTrue(posts[0].longitude == post.longitude)
   		assertTrue(posts[0].latitude == post.latitude)

   		#gets all two posts within distance 2, should get 2 posts in the UK
   		posts = post.get_nearby_posts(distance2)
   		assertTrue(posts.size() == 2)
   		assertTrue(posts[0].longitude == longitude)
   		assertTrue(posts[0].latitude == latitude)
   		assertTrue(posts[1].longitude == hackney_longitude)
   		assertTrue(posts[1].latitude == hackney_latitude)
   		
   		#gets all three posts within distance 3
   		posts = post.get_nearby_posts(distance3)
   		assertTrue(posts.size() == 3)
   		assertTrue(posts[0].longitude == longitude)
   		assertTrue(posts[0].latitude == latitude)
   		assertTrue(posts[1].longitude == hackney_longitude)
   		assertTrue(posts[1].latitude == hackney_latitude)
   		assertTrue(posts[2].longitude == aus_longitude)
   		assertTrue(posts[2].latitude == aus_latitude)




if __name__ == '__main__':
    unittest.main()
