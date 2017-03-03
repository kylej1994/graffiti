import json
import sys
import unittest
import base64


from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti, user
from graffiti.user import User


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
    def test_create_user(self):
        rv = self.create_user()
        assert rv.status_code == 200

        data = json.loads(rv.data)
        # first user made, id is assigned but not other values
        print data
        assert data['new_user'] == True
        self.check_user_fields(data['user'], 2, '', '', '', '', '')

    def test_login_existent_user(self):
        # logging in with debug idToekns from auth_middleware.py
        rv = self.app.get('/user/login',
                follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        assert data['new_user'] == False

    def test_get_existent_user(self):
        # Uses the sample user made in graffiti.py
        rv = self.app.get('/user/1',
                follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        # first user made, id is assigned but not other values
        self.check_user_fields(data, 1, 'easmith', 'Emma Smith', 'kat@lu.com', \
            'My name is jablonk' , '9172825753')

    def test_get_nonexistent_user_by_user_id(self):
        # two users made in graffiti.py
        rv = self.app.get('/user/17',
                follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "User not found."

    def test_update_nonexistent_user(self):
        rv = self.app.put('/user/2',
                data=dict(),
                follow_redirects=True)

        assert rv.status_code == 400

        data = json.loads(rv.data)
        assert data['error'] == "User information is invalid."

    def test_update_existent_user(self):
        # Uses the sample user made in graffiti.py
        # note that userid and emails are immutable
        rv = self.app.put('/user/1',
                data=json.dumps(dict(
                    userid=1,
                    username='l33t',
                    name='Team Graffiti',
                    email='kat@lu.com',
                    bio='This is my tag.',
                    phone_number='1234567890',
                    img_tag=[]
                    )),
                content_type='application/json',
                follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        self.check_user_fields(data, 1, 'l33t', 'Team Graffiti',
            'kat@lu.com', 'This is my tag.', '1234567890')

    def test_update_existent_user_with_image(self):
        with open('cat-pic.png', 'rb') as imageFile:
            img_data = base64.b64encode(imageFile.read())
        # Uses the sample user made in graffiti.py
        # note that userid and emails are immutable
        rv = self.app.put('/user/1',
                data=json.dumps(dict(
                    userid=1,
                    username='l33t',
                    name='Team Graffiti',
                    email='kat@lu.com',
                    bio='This is my tag.',
                    phone_number='1234567890',
                    img_tag=img_data
                    )),
                content_type='application/json',
                follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        self.check_user_fields(data, 1, 'l33t', 'Team Graffiti',
            'kat@lu.com', 'This is my tag.', '1234567890')

    def test_get_user_posts(self):
        rv = self.app.get('/user/1/posts',
                follow_redirects=True)

        assert rv.status_code == 200

    def test_get_nonexistent_user_posts(self):
        # 2 users made in graffiti.py
        rv = self.app.get('/user/17/posts',
                follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "User not found."


if __name__ == '__main__':
    unittest.main()
