import requests
import os

#'export DEBUG=True' to set to true
#DEBUG: Flag to skip authorization
DEBUG = os.getenv('DEBUG', False)
if DEBUG == 'True':
    DEBUG = True
else: 
    DEBUG = False

from oauth2client import client, crypt
from werkzeug.wrappers import Request

GOOGLE_CLIENT_ID = '360596307324-h5h550nfr8l1tfp2nk095d8d0vmeuonb.apps.googleusercontent.com'
GOOGLE_CLIENT_SECRET = 'FG4gWI2naIbjkcSxEvZyE6Bb'

class Auth_MiddleWare(object):
    '''
    Auth WSGI middleware
    '''

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        print 'something you want done in every http request'

        environ['NOID'] = False
        environ['BADTOKEN'] = False
        environ['META_INFO'] = None

        #Skip Auth if debugging, since tokens will always be invalid
        if DEBUG:
            return self.app(environ, start_response)


        request = Request(environ, shallow=True)
        token = request.headers.get('idToken')
        if token is None:
            environ['NOID'] = True
            print 'idtoken field is none'
            return self.app(environ, start_response)


        #Successful Validation
        try:
            idinfo = client.verify_id_token(token, GOOGLE_CLIENT_ID)
            audCode = idinfo['aud']
            gmail = idinfo['email']
            # user_id = 
            return_info = dict([('email', gmail), ('audCode', audCode)])

            #Return return_info w/ self.app
            print 'Successful validation'
            environ['META_INFO'] = return_info

        #Unsuccessful validation
        except crypt.AppIdentityError:
            environ['BADTOKEN'] = True
            print 'Invalid token'

        return self.app(environ, start_response)
