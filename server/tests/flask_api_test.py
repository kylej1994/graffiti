import os
import sys
import unittest
import tempfile
import json

sys.path.append('..')
from graffiti import graffiti

class APITestCase(unittest.TestCase):

    # setUp and tearDown are called before and after each test function
    # is run, respectively.

    def setUp(self):
        self.db_fd, graffiti.app.config['DATABASE'] = tempfile.mkstemp()
        graffiti.app.config['TESTING'] = True
        self.app = graffiti.app.test_client()
        with graffiti.app.app_context():
            # initializes the database that is used
            graffiti.init_db()

    def tearDown(self):
        os.close(self.db_fd)
        os.unlink(graffiti.app.config['DATABASE'])


    """ Posts related API calls. """
    def test_empty_db(self):
        post_text = 'omg first graffiti post'
        lat = 29.12123
        lon = 32.12943
        created_at = 0.1
        poster_username = 'jeffdean'
        rv = self.app.post('/posts/create',
                data=dict(
                    latitude=lat,
                    longitude=lon,
                    created_at = created_at,
                    poster = poster_username),
            follow_redirects=True)
        assert rv.status_code == 200

        data = json.loads(rv.data)
        assert data['lat'] == lat
        assert data['lon'] == lon
        assert data['created_at'] == 0.1
        assert data['poster'] == poster_username

if __name__ == '__main__':
    unittest.main()
