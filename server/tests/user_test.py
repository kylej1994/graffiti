import json
import os
import sys
import tempfile
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti, user
from graffiti.user import User
from graffiti.post import Post
from graffiti.graffiti import db

user_id = 1

class UserTestCase(unittest.TestCase):

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

    def test_get_user_id(self):
        test_user = db.session.query(User).filter(User.username=="easmith").first()
        self.assertTrue(test_user.get_user_id() == user_id)

    def test_get_username(self):
        test_user = db.session.query(User).filter(User.username=="easmith").first()
        self.assertTrue(test_user.get_username() == 'easmith')

    def test_get_phone_number(self):
        test_user = db.session.query(User).filter(User.username=="easmith").first()
        self.assertTrue(test_user.get_phone_number() == '9172825753')

    def test_get_name(self):
        test_user = db.session.query(User).filter(User.username=="easmith").first()
        self.assertTrue(test_user.get_name() == 'Emma Smith')

    def test_get_bio(self):
        test_user = db.session.query(User).filter(User.username=="easmith").first()
        self.assertTrue(test_user.get_bio() == 'My name is jablonk')

    def test_get_user(self):
        test_user = User.find_user_by_id(user_id)
        print test_user.google_aud

        self.assertTrue(test_user.username == "easmith")
        #Normally our aud is longer than just a number, but our default database nubmers are more complicated
        self.assertTrue(test_user.google_aud == "1008719970978")
        self.assertTrue(test_user.has_been_suspended == False)
        self.assertTrue(test_user.name == 'Emma Smith')
        self.assertTrue(test_user.email == 'kat@lu.com')
        self.assertTrue(test_user.bio == 'My name is jablonk')
        no_user = User.find_user_by_id(1000)
        self.assertIsNone(no_user)

    def test_change_suspension(self):
        test_user = db.session.query(User).filter(User.username=="easmith").first()
        test_user.set_has_been_suspended(True)
        self.assertTrue(db.session.query(User)
            .filter(User.username=="easmith").first().has_been_suspended == True)
        test_user.set_has_been_suspended(True)
        self.assertTrue(db.session.query(User)
            .filter(User.username=="easmith").first().has_been_suspended == True)
        test_user.set_has_been_suspended(False)
        self.assertTrue(db.session.query(User)
            .filter(User.username=="easmith").first().has_been_suspended == False)

    def test_save_user(self):
        user = User("easmith3", 
            "B1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
            "9172825753", "name", "email@email.com", "text_tag")
        user.save_user()
        self.assertIsNotNone(db.session.query(User).filter(User.username=='easmith3').first())
        user.delete_user()

    def test_delete_user(self):
        # Below function has not yet been implemented
        user = User("easmith2", 
            "A1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
            "9172825753", "name", "email@email.com", "text_tag")
        user.save_user()
        user.delete_user()
        self.assertIsNone(db.session.query(User).filter(User.username=="easmith2").first())

    # checks that the google_aud part of the compound key of User
    # retrieves and identifies the right user
    def test_get_user_by_google_aud(self):
        google_aud = "A1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com"
        user = User("easmith2", 
            google_aud, "9172825753", "name", "email@email.com", "text_tag")
        user.save_user()
        gotten = User.get_user_by_google_aud(google_aud)
        self.assertIsNotNone(gotten)
        self.assertTrue(gotten.user_id == user.user_id)
        self.assertTrue(gotten.google_aud == google_aud)
        user.delete_user()


    ## testing setters

    # tests username for between 3 - 25 characters
    def test_set_username(self):
        user = User("easmith3", 
            "B1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
            "9172825753", "name", "email@email.com", "text_tag")
        invalid_username = 'abcdefghijklmnopqrstuvwxyz'
        valid_username = 'abcdefghijklmnopqrstuvwxy'
        self.assertFalse(user.set_username(invalid_username))
        self.assertTrue(user.set_username(valid_username))
        invalid_username = 'ab'
        valid_username = 'abc'
        self.assertFalse(user.set_username(invalid_username))
        self.assertTrue(user.set_username(valid_username))

    def test_set_phone_number(self):
        user = User("easmith3", 
            "B1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
            "9172825753", "name", "email@email.com", "text_tag")
        invalid_phone = '123456789012'
        valid_phone = '1234567890'
        self.assertFalse(user.set_phone_number(invalid_phone))
        self.assertTrue(user.set_phone_number(valid_phone))

    def test_set_name(self):
        user = User("easmith3", 
            "B1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
            "9172825753", "name", "email@email.com", "text_tag")
        invalid_name = "2348!*384"
        invalid_name2 = 'B1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6\
        381.apps.googleusercontent.comB1008719970978-hb24n2dstb40o45d\
        4feuo2ukqmcc6381.apps.googleusercontent.comB1008719970978-hb2'
        valid_name = 'ron1'
        valid_name2 = 'kyle'
        self.assertFalse(user.set_name(invalid_name))
        self.assertFalse(user.set_name(invalid_name2))
        self.assertTrue(user.set_name(valid_name))
        self.assertTrue(user.set_name(valid_name2))

    # iteration 2 tests
    # tests that the stored image location matches the picture associated w user
    # Can't test since back-end isn't currently storing images
    def test_get_img_file_loc(self):
        img_url = 'some_url_tbd'
        user = db.session.query(User).filter(User.user_id==user_id).first()
        self.assertTrue(user.get_img_file_loc() == img_url)


if __name__ == '__main__':
    unittest.main()