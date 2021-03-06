import json
import os
import sys
import tempfile
import unittest

sys.path.append('..')
from graffiti import graffiti, user, userpost, post
from graffiti.user import User
from graffiti.post import Post
from graffiti.userpost import UserPost
from graffiti.graffiti import db

user_id = 1
post_id = 1
vote = 1

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

    def test_get_user_id(self):
        Post.apply_vote(user_id, post_id, vote)
        userpost = db.session.query(UserPost).filter(UserPost.user_id==user_id)\
            .filter(UserPost.post_id==post_id).first()
        self.assertTrue(userpost.get_user_id() == user_id)

    def test_get_post_id(self):
        Post.apply_vote(user_id, post_id, vote)
        userpost = db.session.query(UserPost).filter(UserPost.user_id==user_id)\
            .filter(UserPost.post_id==post_id).first()
        self.assertTrue(userpost.get_post_id() == post_id)

    def test_get_vote(self):
        Post.apply_vote(user_id, post_id, vote)
        userpost = db.session.query(UserPost).filter(UserPost.user_id==user_id)\
            .filter(UserPost.post_id==post_id).first()
        self.assertTrue(userpost.get_vote() == vote)

    def test_get_votes_by_ids(self):
        Post.apply_vote(user_id, post_id, vote)
        fetched_vote = UserPost.get_vote_by_ids(user_id, post_id)
        self.assertTrue(fetched_vote == vote)

    

if __name__ == '__main__':
    unittest.main()