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
        with graffiti.app.app_context():
            # initializes the database that is used
            graffiti.init_db()

    def tearDown(self):
        os.close(self.db_fd)
        os.unlink(graffiti.app.config['DATABASE'])


if __name__ == '__main__':
    unittest.main()