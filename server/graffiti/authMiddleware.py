import requests
import os
#'export DEBUG=True' to set to true
DEBUG = os.getenv('DEBUG', False)
if DEBUG == 'True':
    DEBUG = True
else: 
    DEBUG = False


from flask import Flask, Blueprint, request, url_for
from oauth2client import client, crypt
from werkzeug.wrappers import Request

GOOGLE_CLIENT_ID = '360596307324-h5h550nfr8l1tfp2nk095d8d0vmeuonb.apps.googleusercontent.com'
GOOGLE_CLIENT_SECRET = 'FG4gWI2naIbjkcSxEvZyE6Bb'

class AuthMiddleWare(object):
    '''
    Auth WSGI middleware
    '''

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        print 'something you want done in every http request'

        #Skip Auth if debugging, since tokens will always be invalid
        if DEBUG:
            return self.app(environ, start_response)


        environ['NOID'] = False
        environ['BADTOKEN'] = False
        environ['EMAIL'] = None
        
        request = Request(environ, shallow=True)
        token = request.headers.get('idToken')
        if token is None:
            environ['NOID'] = True
            print 'idtoken field is none'


        #Successful Validation
        try:
            idinfo = client.verify_id_token(token, GOOGLE_CLIENT_ID)
            audCode = idinfo['aud']
            gmail = idinfo['email']
            return_info = dict([('email', gmail)])

            #Return return_info w/ self.app
            print 'Successful validation'
            environ['EMAIL'] = return_info

        #Unsuccessful validation
        except crypt.AppIdentityError:
            environ['BADTOKEN'] = True
            print 'Invalid token\n'

        return self.app(environ, start_response)