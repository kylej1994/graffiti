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
                content_type='application/json',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

    # the data should be in json format
    def check_post_fields(self,
            data, post_id, text, location, num_votes):
        assert data['postid'] == post_id
        assert data['text'] == text
        # location is a dict with two fields, latitude and longitude
        assert data['location'] == location
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
        # postid 6 because 5 posts made in graffiti.py
        self.check_post_fields(data, 6, post_text, location, 0)

    def test_create_invalid_post(self):
        # no location fields, hence, invalid
        data=json.dumps(dict(text='invalid post, sucks'))
        rv = self.app.post('/post',
                data = data,
                content_type='application/json',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 400

        data = json.loads(rv.data)
        assert data['error'] == "Post information was invalid."

    def test_delete_post(self):
        # request to delete post with postid 1
        # using the sample post
        rv = self.app.delete('/post/1',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 200

    def test_delete_nonexistent_post(self):
        # post with postid=7 does not exists
        rv = self.app.delete('/post/7',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "Post not found."

    def test_delete_post_invalid_owner(self):
        # The debugging auth has the hardcoded values for user with id 1, and
        # this call attempts to delete a post made by user with id 2, i.e.
        # this is not good behaviour
        rv = self.app.delete('/post/5',
            follow_redirects=True)

        assert rv.status_code == 403

        data = json.loads(rv.data)
        assert data['error'] == "Post is not owned by user."

    def test_get_post(self):
        location = dict(
            longitude=51.5192028, 
            latitude=-0.140863)

        rv = self.app.get('/post/2',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)
        self.check_post_fields(data, 2, 'text2', location, 0)

    def test_get_nonexistent_post(self):
        rv = self.app.get('/post/10',
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 404

        data = json.loads(rv.data)
        assert data['error'] == "Post not found."

    def test_get_post_by_location(self):
        location = dict(
            longitude=-51.5192028, 
            latitude=0.140863)
        rv = self.app.get("/post?longitude=-51.5192028&latitude=0.140863",
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)

        assert rv.status_code == 200

        data = json.loads(rv.data)['posts']
        self.check_post_fields(
            data[0], 3, 'post_location_1', location, 0)
        self.check_post_fields(
            data[1], 4, 'post_location_2', location, 0)

    # def test_vote_on_post(self):
    #     post_text = 'omg first graffiti post'
    #     lat = 29.12123
    #     lon = 32.12943
    #     location = dict(
    #         latitude=lat,
    #         longitude=lon)
    #     self.create_post(post_text, location)

    #     # upvote by 1 vote, twice
    #     self.app.put('/post/postid=1',
    #             data=dict(vote=1),
    #             headers=dict(
    #                 idToken=9402234123712),
    #         follow_redirects=True)
    #     rv = self.app.put('/post/postid=1',
    #             data=dict(vote=1),
    #             headers=dict(
    #                 idToken=9402234123712),
    #         follow_redirects=True)

    #     assert rv.status_code == 200

    #     data = json.loads(rv.data)
    #     assert data['postid'] == 1
    #     assert data['num_vote'] == 2

    # def test_vote_on_nonexistent_post(self):
    #     rv = self.app.put('/post/postid=1',
    #             data=dict(vote=1),
    #             headers=dict(
    #                 idToken=9402234123712),
    #         follow_redirects=True)

    #     assert rv.status_code == 404

    #     data = json.loads(rv.data)
    #     assert data['error'] == "Post not found."


if __name__ == '__main__':
	unittest.main()