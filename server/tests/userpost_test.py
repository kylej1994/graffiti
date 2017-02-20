import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti, db
from graffiti.models import User, UserPost

import geoalchemy

class UserPostTestCase(unittest.TestCase):

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