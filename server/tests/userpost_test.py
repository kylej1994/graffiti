import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti, db
from graffiti.models import User #this doesnt exist yet

import geoalchemy
from geoalchemy.postgis import PGComparator

class UserPostTestCase(APITestCase):

    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()
        db.create_all()
        db.session.add(UserPost("easmith", 
            1,
            False))
        db.session.add(UserPost("easmith", 
            2,
            True))
        db.session.add(UserPost("ron", 
            1,
            False))
        db.session.flush()

    def tearDown(self):
        super(APITestCase, self).tearDown()
        db.session.remove()
        db.drop_all()

    def test_fetch_user(self):
        self.assertTrue(userpost = db.query(UserPost).filter(UserPost.username=="easmith").filter(UserPost.post_id=="2").first())
        self.assertTrue(user.username == "easmith")
        self.assertTrue(user.post_id == 2)
        self.assertTrue(user.vote == True)

        self.assertFalse(userpost2 = db.query(UserPost).filter(UserPost.username=="rony").filter(UserPost.post_id=="1").first())
        
        self.assertTrue(userpost = db.query(UserPost).filter(UserPost.username=="easmith").filter(UserPost.post_id=="1").first())
        self.assertTrue(user.vote == False)

        self.assertFalse(userpost = db.query(UserPost).filter(UserPost.username=="ron").filter(UserPost.post_id=="2").first())
        self.assertTrue(userpost = db.query(UserPost).filter(UserPost.username=="ron").filter(UserPost.post_id=="1").first())
        self.assertTrue(user.vote == False)
    

if __name__ == '__main__':
    unittest.main()