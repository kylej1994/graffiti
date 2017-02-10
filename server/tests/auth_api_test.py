import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti

class AuthTestCase(APITestCase):

    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()

    def tearDown(self):
        super(APITestCase, self).tearDown()

    '''Test auth with invalid authorization'''
    '''Test nonsensical auth'''
    '''Test valid authorization'''
    
if __name__ == '__main__':
    unittest.main()
