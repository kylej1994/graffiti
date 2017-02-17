import json
import sys
import unittest

from flask_api_test import APITestCase
sys.path.append('..')
from graffiti import graffiti

test_idtoken = '''eyJhbGciOiJSUzI1NiIsImtpZCI6IjgxM2QzNjVmZWJjZDhkZjE2YjZlZTlhOGNhZThjNTQ1NmUxYzNjYjYifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJpYXQiOjE0ODcyMjU5MzcsImV4cCI6MTQ4NzIyOTUzNywiYXRfaGFzaCI6Ik5VME12eVNfRVcxS29ydjdjZExYbXciLCJhdWQiOiI0MDc0MDg3MTgxOTIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDA5NDQ4NDQ0OTU0MDgyMzc2NjUiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiNDA3NDA4NzE4MTkyLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJ1Y2hpY2Fnby5lZHUiLCJlbWFpbCI6ImphYmxvbmtAdWNoaWNhZ28uZWR1IiwibmFtZSI6Ikt5bGUgSmFibG9uIiwicGljdHVyZSI6Imh0dHBzOi8vbGg0Lmdvb2dsZXVzZXJjb250ZW50LmNvbS8tNVowMm5Vb05pUG8vQUFBQUFBQUFBQUkvQUFBQUFBQUFBQUEvQURQbGhmSk9LZGpmZ1oxeW9GdVFrQXg4YW9MdndlVDBsZy9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiS3lsZSIsImZhbWlseV9uYW1lIjoiSmFibG9uIiwibG9jYWxlIjoiZW4ifQ.DgWiLVyIKsuJ3WNzNT41v8laT0LGnHEOVhFk7HWvC_EztgkIPv-fZIMRlVrs1F9m5QGzYpd9eBvPfUdXm4akTn7uKsvmkRmJ30CMO4c4NimRIyBf-XK3eVKKc9f5wQ4rRHp0d3C2mEkClgH3ii_msDauqohboxbLReuyAz8_0NWnDzoo-dztARmysBG-Uttcte98KRxGUx71s3nMWp797REwoevBIz8eeGz8unZFdy0YBgYu4kSpkKNyPxarANTiGdJ607XJfo7TlSN3yUoD3cOMJPHjMEynqY0gzZu4aFuEMw6VcuhzoWf0fQKz4ENMsa3FnOD7ysMt5O1-PhzLaw'''

class AuthTestCase(APITestCase):


    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()

    def tearDown(self):
        super(APITestCase, self).tearDown()


    #Return Json of auth
    def create_auth_json(self, token):
        rv = self.app.put('/',
            headers=dict(
                idToken=token),
            follow_redirects=True)

        return rv

    '''Auth Tests'''
    #Test auth with no Authorization token
    def test_no_token(self):
        rv = self.app.get('/post',
            follow_redirects=True)

        assert rv.status_code == 400

    #Test auth with invalid user. Expects FALSE, for invalid auth code
    def test_create_invalid_auth(self):
        test_string = 'test_token_string'
        rv = self.create_auth_json(test_idtoken)

        assert rv.status_code == 400

    #Test to Create a valid authentication object & testing its properties
    def test_create_valid_auth(self):
        #Create auth obj
        rv = self.create_auth_json(test_idtoken)
        authData = json.loads(rv.data)

        #Try authenticating it
        assert rv.status_code == 200



if __name__ == '__main__':
    unittest.main()
