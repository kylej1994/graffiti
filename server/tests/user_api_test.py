import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti, db
from graffiti.models import User #this doesnt exist yet

import geoalchemy
from geoalchemy.postgis import PGComparator

class UserTestCase(APITestCase):

    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()
        db.create_all()
        db.session.add(User("easmith", 
        	"1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
        	"9172825753"))
        db.session.flush()

    def tearDown(self):
        super(APITestCase, self).tearDown()
        db.session.remove()
        db.drop_all()

   	def test_fetch_user(self):
   		user = db.query(User).filter(User.username=="easmith").first()
        self.assertTrue(user.username == "easmith")
        self.assertTrue(user.google_aud == "1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com")
        self.assertTrue(user.has_been_suspended == False)

    def test_set_username(self):
   		# Below function on restrictions on username creation have not yet been implemented
   		self.assertFalse(db.session.add(User("!easmith", 
        	"1",
        	"9172825751"))
   		self.assertFalse(db.session.add(User("s*smith", 
        	"1",
        	"9172825751"))
   		self.assertFalse(db.session.add(User("easmith-", 
        	"1",
        	"9172825751"))
   		self.assertFalse(db.session.add(User("easmieasmieasmieasmieasmi", 
        	"1",
        	"9172825751"))

   	def test_set_phone_number(self):
   		# Below function on restrictions on phone number creation have not yet been implemented
   		self.assertFalse(db.session.add(User("easmith", 
        	"1",
        	"91728257511"))
   		self.assertFalse(db.session.add(User("easmith", 
        	"1",
        	"917282575"))
   		self.assertTrue(db.session.add(User("easmith", 
        	"1",
        	"917-282-5751"))
   		self.assertTrue(db.session.add(User("easmith", 
        	"1",
        	"917-28257-51"))
   		self.assertTrue(db.session.add(User("easmith", 
        	"1",
        	"---9172825751"))
   		self.assertTrue(db.session.add(User("easmith", 
        	"1",
        	"917282875a"))

    def test_change_suspension(self):
   		user = db.query(User).filter(User.username=="easmith").first()
   		# Below function has not yet been implemented
   		user.change_suspension(True);
        self.assertTrue(db.query(User).filter(User.username=="easmith").first().has_been_suspended == True)
        user.change_suspension(True);
        self.assertTrue(db.query(User).filter(User.username=="easmith").first().has_been_suspended == True)
        user.change_suspension(False);
        self.assertTrue(db.query(User).filter(User.username=="easmith").first().has_been_suspended == False)

    def test_adding_duplicate_user_parameters(self):
    	# Duplicate username
        self.assertFalse(db.session.add(User("easmith", 
        	"auth",
        	"6462825753")))
        
        # Duplicate auth
        self.assertFalse(db.session.add(User("willem", 
        	"1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
        	"4462825753")))
        
        # Duplicate phone
        self.assertFalse(db.session.add(User("ron", 
        	"444-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
        	"9172825753")))

        # No duplicates
        self.assertTrue(db.session.add(User("amanda", 
        	"4344-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
        	"5172825753")))

   	def test_delete_user(self):
   		# Below function has not yet been implemented
   		user2 = User("ron", "4555", "9274859273")
   		assertFalse(user2.delete())

   		user = db.query(User).filter(User.username=="easmith").first()
   		assertTrue(user.delete())

   		assertIsNone(db.query(User).filter(User.username=="easmith").first())



if __name__ == '__main__':
    unittest.main()