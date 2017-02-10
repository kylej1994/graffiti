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
        return self.app.get('/users/login',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

    # the data should be in json format
    def check_user_fields(self, data, userId, username, name, email, textTag):
        assert data['userId'] == userId
        assert data['username'] == username
        assert data['name'] == name
        assert data['email'] == email
        assert data['textTag'] == textTag

    """ User related API calls. """
    def test_create_user(self):
        rv = self.create_user()

        assert rv.status_code == 200

        data = json.loads(rv.data)
        # first user made, id is assigned but not other values
        self.check_user_fields(data, 1, '', '', '', '')

    def test_invalid_create_user(self):
        rv = self.app.get('/users/login',
                follow_redirects=True)

        # no idToken header, so is an unauthorized request
        assert rv.status_code == 401

        data = json.loads(rv.data)
        assert data['error'] == "User idToken is missing."

    def test_get_existent_user(self):
        # creates a user with userId: 1
        self.create_user()
        rv = self.app.get('/users/1',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        # first user made, id is assigned but not other values
        self.check_user_fields(data, 1, '', '', '', '')

    def test_get_nonexistent_user_by_user_id(self):
        rv = self.app.get('/users/1',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "User not found."

    def test_update_nonexistent_user(self):
        rv = self.app.put('/users/1',
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "User not found."

    def test_update_existent_user(self):
        # creates a user with userId: 1
        self.create_user()

        rv = self.app.put('/users/1',
                data=dict(
                    userid=1,
                    username='l33t',
                    name='Team Graffiti',
                    email='team@graffiti.com',
                    textTag='This is my tag.'
                    ),
                headers=dict(
                    idToken=9402234123712),
                follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        self.check_user_fields(data, 1, 'l33t',
            'Team Graffiti', 'team@graffiti.com', 'This is my tag.')


if __name__ == '__main__':
    unittest.main()
