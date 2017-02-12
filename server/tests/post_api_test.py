import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti

class PostTestCase(APITestCase):

    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()

    def tearDown(self):
        super(APITestCase, self).tearDown()

    def create_post(self, post_text, location):
        data=json.dumps(dict(
                    text=post_text,
                    location=location))
        return self.app.post('/post',
                data=data,
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

    # the data should be in json format
    def check_post_fields(self,
            data, post_id, text, location, created_at, poster_id, num_votes):
        assert data['postid'] == post_id
        assert data['text'] == text
        # location is a dict with two fields, latitude and longitude
        assert data['location'] == location
        assert data['created_at'] == created_at
        assert data['posterid'] == poster_id
        assert data['num_votes'] == num_votes


    """ Post related API calls. """    
    def test_create_post(self):
        post_text = 'omg first graffiti post'
        lat = 29.12123
        lon = 32.12943
        location = dict(
            latitude=lat,
            longitude=lon)
        rv = self.create_post(post_text, location)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        self.check_post_fields(data, 1, post_text, location, 1, 'jeffdean', 0)

    def test_create_invalid_post(self):
        # no location fields, hence, invalid
        data=json.dumps(dict(text='invalid post, sucks'))
        rv = self.app.post('/post',
                data = data,
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 400

        data = json.loads(rv.data)
        assert data['error'] == "Post information was invalid."

    def test_delete_post(self):
        # creates post with postid 1
        post_text = 'omg first graffiti post'
        lat = 29.12123
        lon = 32.12943
        location = dict(
            latitude=lat,
            longitude=lon)
        rv = self.create_post(post_text, location)


        # request to delete post with postid 1
        rv = self.app.delete('/post/postid=1',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 200

    def test_delete_nonexistent_post(self):
        rv = self.app.delete('/post/postid=1',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "Post not found."

    def test_delete_post_invalid_owner(self):
        # creates post with postid 1
        post_text = 'omg first graffiti post'
        lat = 29.12123
        lon = 32.12943
        location = dict(
            latitude=lat,
            longitude=lon)
        rv = self.create_post(post_text, location)


        # request has no idToken in the header
        rv = self.app.delete('/post/postid=1',
            follow_redirects=True)

        assert rv.status_code == 403

        data = json.loads(rv.data)
        assert data['error'] == "Post is not owned by user."

    def test_get_post(self):
        post_text = 'omg first graffiti post'
        lat = 29.12123
        lon = 32.12943
        location = dict(
            latitude=lat,
            longitude=lon)
        rv = self.create_post(post_text, location)


        rv = self.app.get('/post/postid=1',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        self.check_post_fields(data, 1, post_text, location, 1, 'jeffdean', 0)

    def test_get_nonexistent_post(self):
        rv = self.app.get('/post/postid=1',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "Post not found."

    def test_get_post_by_location(self):
        post_text1 = 'omg first graffiti post'
        lat = 29.12123
        lon = 32.12943
        location = dict(
            latitude=lat,
            longitude=lon)
        self.create_post(post_text1, location)


        post_text2 = 'omg second graffiti post'
        self.create_post(post_text2, location)

        rv = self.app.get('/post/longitude=32.12943&latitude=29.12123',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        self.check_post_fields(
            data[0], 1, post_text1, location, 1, 'jeffdean', 0)
        self.check_post_fields(
            data[1], 2, post_text2, location, 2, 'jeffdean', 0)

    def test_vote_on_post(self):
        post_text = 'omg first graffiti post'
        lat = 29.12123
        lon = 32.12943
        location = dict(
            latitude=lat,
            longitude=lon)
        self.create_post(post_text, location)

        # upvote by 1 vote, twice
        self.app.put('/post/postid=1',
                data=dict(vote=1),
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)
        rv = self.app.put('/post/postid=1',
                data=dict(vote=1),
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        assert data['postid'] == 1
        assert data['num_vote'] == 2

    def test_vote_on_nonexistent_post(self):
        rv = self.app.put('/post/postid=1',
                data=dict(vote=1),
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "Post not found."


if __name__ == '__main__':
	unittest.main()