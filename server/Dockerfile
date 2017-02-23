FROM ubuntu:14.04

# This is the template for a Dockerfile from 2.5+ years ago, so idk if this is right...

# Still need to install postgis and initdb, createdb, create the extension, etc.

RUN apt-get update

RUN apt-get install -yy python-dev

RUN apt-get clean

RUN pip install flask
RUN pip install flask-assets
RUN pip install flask-script
RUN pip install flask-sqlalchemy
RUN pip install flask-wtf
RUN pip install geoalchemy2
RUN pip install glfw
RUN pip install oauth2client
RUN pip install shapely
RUN pip install sqlalchemy
RUN pip install werkzeug
RUN pip install psycopg2
RUN pip install requests

ADD graffiti/__init__.py /graffiti/__init__.py