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

    def check_post_fields(self,
        data, post_id, location, created_at, poster_id, num_votes)

    """ Post related API calls. """    
    def test_empty_db(self):
        post_text = 'omg first graffiti post'
        lat = 29.12123
        lon = 32.12943
        created_at = 0.1
        poster_username = 'jeffdean'
        rv = self.app.post('/posts/create',
                data=dict(
                    latitude = lat,
                    longitude = lon,
                    created_at = created_at,
                    poster = poster_username),
                headers=dict(
                    idToken=9402234123712),
            follow_redirects=True)
        assert rv.status_code == 200

        data = json.loads(rv.data)
        assert data['lat'] == lat
        assert data['lon'] == lon
        assert data['created_at'] == 0.1
        assert data['poster'] == poster_username


if __name__ == '__main__':
    unittest.main()
