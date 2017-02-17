import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti

class UserTestCase(APITestCase):

    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()

    def tearDown(self):
        super(APITestCase, self).tearDown()

    def create_user(self):
        return self.app.get('/user/login',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

    # the data should be in json format
    def check_user_fields(
        self, data, user_id, username, name, email, bio, ph_num):
        assert data['userid'] == user_id
        assert data['username'] == username
        assert data['name'] == name
        assert data['email'] == email
        assert data['bio'] == bio
        assert data['phone_number'] == ph_num

    """ User related API calls. """
    # def test_create_user(self):
    #     rv = self.create_user()
    #     print rv.status_code
    #     assert rv.status_code == 200

    #     data = json.loads(rv.data)
    #     # first user made, id is assigned but not other values
    #     assert data['new_user'] == True
    #     self.check_user_fields(data['user'], 2, '', '', '', '', '')

    # def test_invalid_create_user(self):
    #     rv = self.app.get('/user/login',
    #             follow_redirects=True)

    #     # no idToken header, so is an unauthorized request
    #     assert rv.status_code == 401

    #     data = json.loads(rv.data)
    #     assert data['error'] == "User idToken is missing."

    def test_get_existent_user(self):
        # Uses the sample user made in graffiti.py
        rv = self.app.get('/user/1',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        # first user made, id is assigned but not other values
        self.check_user_fields(data, 1, 'easmith', 'Emma Smith', 'kat@lu.com', \
            'My name is jablonk' , '9172825753')

    def test_get_nonexistent_user_by_user_id(self):
        rv = self.app.get('/user/2',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "User not found."

    def test_update_nonexistent_user(self):
        rv = self.app.put('/user/2',
                data=dict(),
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 400

        data = json.loads(rv.data)
        assert data['error'] == "User information is invalid."

    def test_update_existent_user(self):
        # Uses the sample user made in graffiti.py

        rv = self.app.put('/user/1',
                data=json.dumps(dict(
                    userid=1,
                    username='l33t',
                    name='Team Graffiti',
                    email='team@graffiti.com',
                    bio='This is my tag.',
                    phone_number='1234567890'
                    )),
                content_type='application/json',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        self.check_user_fields(data, 1, 'l33t', 'Team Graffiti',
            'team@graffiti.com', 'This is my tag.', '1234567890')

    def test_get_user_posts(self):
        rv = self.app.get('/user/1/posts',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 200

    def test_get_nonexistent_user_posts(self):
        rv = self.app.get('/user/2/posts',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "User not found."


if __name__ == '__main__':
    unittest.main()
