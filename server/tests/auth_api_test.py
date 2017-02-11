import json
import sys
import unittest

from flask_api_test import APITestCase
from flask_sqlalchemy import SQLAlchemy
sys.path.append('..')
from graffiti import graffiti, db
from graffiti.models import Auth #this doesnt exist yet

class AuthTestCase(APITestCase):


    def setUp(self):
        super(APITestCase, self).setUp()
        self.app = graffiti.app.test_client()
        self.db = SQLAlchemy(self.app)

    def tearDown(self):
        super(APITestCase, self).tearDown()

    def test_auth_fields(self, auth, token, is_expired):
        assert auth.token == token
        assert auth.is_expired == is_expired

    def is_same_auth(self, auth1, auth2):
        assert auth1.token == auth2.token
        assert auth1.is_expired == auth2.is_expired

    #Return Json of auth
    def create_auth_json(self, token):
        rv = self.app.put('/auth',
            headers=dict(
                authToken=token),
            follow_redirects=True)

        authJson = json.loads(rv.data)
        return authJson

    '''Auth Tests'''
    #Test auth with no Authorization token
    def test_no_token(self):
        rv = self.app.get('/auth',
            follows_redirects=True)

        assert rv.status_code == 401

    #Test auth with invalid user. Expects FALSE, for invalid auth code
    def test_create_invalid_auth(self):
        test_string = 'test_token_string'
        authJson = self.create_auth_json(test_string)

        #Confirm format of auth
        assert str == type(authJson.aud)
        assert ('.apps.googleusercontent.com' in authJson.aud) == True 

        #Return false for invalid authorization
        authObj = Auth(authJson)
        assert authObj == False


    def test_create_valid_auth(self):
        #Create auth obj
        test_string = '1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com'
        authJson = self.create_auth_json(test_string)
        authObj = Auth(authJson)

        #Try authenticating it
        authObj = Auth('1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com')
        assert authObj.token == test_string
        assert authObj.is_expired == True

    def test_store_auth(self):
        #Create auth obj
        test_string = '1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com'
        authJson = self.create_auth_json(test_string)
        authObj = Auth(authJson)

        #Try dading and deleting
        self.db.session.add(authObj)
        self.db.session.delete(authObj)
        self.commit()

    def test_get_auth(self):
        test_string = '1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com'
        authJson = self.create_auth_json(test_string)
        authObj = Auth(authJson)

        self.db.session.add(authObj)
        queriedAuth = Auth.query.filter(token=test_string)
        self.is_same_auth(authObj, queriedAuth)
        self.db.session.delete(authObj)


if __name__ == '__main__':
    unittest.main()
