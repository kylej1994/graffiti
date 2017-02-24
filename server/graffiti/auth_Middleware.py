import requests
import os
import re

#'export DEBUG=True' to set to true
#DEBUG: Flag to skip authorization
DEBUG = os.getenv('DEBUG', False)
if DEBUG == 'True':
    DEBUG = True
else:
    DEBUG = False

from oauth2client import client, crypt
from werkzeug.wrappers import Request

GOOGLE_CLIENT_ID = '13231237482-s7mfuli2va5deig9q2a20r8ju54duojp.apps.googleusercontent.com'
GOOGLE_CLIENT_SECRET = 'FG4gWI2naIbjkcSxEvZyE6Bb'

class Auth_MiddleWare(object):
    '''
    Auth WSGI middleware
    '''

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        print 'Auth middleware call'

        environ['NOID'] = False
        environ['BADTOKEN'] = False
        environ['META_INFO'] = None

        #Skip Auth if debugging, since tokens will always be invalid
        if DEBUG:
            # testing purposes only - matches with sample values in fill_db()
            return_info = dict([('email', 'kat@lu.com'),\
                ('audCode', '1008719970978')])
            environ['META_INFO'] = return_info
            return self.app(environ, start_response)


        request = Request(environ, shallow=True)

        token = None
        bearerPattern = re.compile('Bearer (.*)')
        tokenPayload = request.headers.get('Authorization')
        if tokenPayload is not None:
            match = bearerPattern.match(tokenPayload)
            if match is not None:
                token = match.group(1)
        if token is None:
            environ['NOID'] = True
            return self.app(environ, start_response)


        #Successful Validation
        try:
            idinfo = client.verify_id_token(token, GOOGLE_CLIENT_ID)
            audCode = idinfo['sub']
            gmail = idinfo['email']
            # user_id =
            return_info = dict([('email', gmail), ('audCode', audCode)])

            #Return return_info w/ self.app
            print 'Successful validation'
            environ['META_INFO'] = return_info

        #Unsuccessful validation
        except crypt.AppIdentityError:
            environ['BADTOKEN'] = True

        return self.app(environ, start_response)
