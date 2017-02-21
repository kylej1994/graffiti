import json
import requests

from flask import Flask, Blueprint, request, url_for
from oauth2client import client, crypt

auth_api = Blueprint('auth_api', __name__)
 

GOOGLE_CLIENT_ID = '360596307324-h5h550nfr8l1tfp2nk095d8d0vmeuonb.apps.googleusercontent.com'
GOOGLE_CLIENT_SECRET = 'FG4gWI2naIbjkcSxEvZyE6Bb'

@auth_api.route('/auth', methods=['GET'])
def auth():
    #Get Token field
    token = request.headers.get('idToken')
    if token is None:
        print 'No id token found for api call'
        return 'No id token\n'

    #Successful Validation
    try:
        idinfo = client.verify_id_token(token, GOOGLE_CLIENT_ID)
        audCode = idinfo['aud']
        gmail = idinfo['email']
        return_info = dict([('email', gmail)])

        return return_info

    #Unsuccessful validation
    except crypt.AppIdentityError:
        return "Invalid token\n"