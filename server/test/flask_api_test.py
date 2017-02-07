import os
import sys
import unittest
import tempfile

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

    def test_empty_db(self):
        rv = self.app.post('/posts', data=dict(
            latitude='29.12123',
            longitude='32.12943'),
            follow_redirects=True)
        # nothing in the database yet, so nothing should be returned
        assert b'' in rv.data

if __name__ == '__main__':
    unittest.main()
