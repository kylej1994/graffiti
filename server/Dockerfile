FROM ubuntu:16.04

# This is the template for a Dockerfile from 2.5+ years ago, so idk if this is right...

# Still need to install postgis and initdb, createdb, create the extension, etc.
# docker build -t graffiti_docker .
# docker run -i -p 5000:5000 graffiti_docker

RUN apt-get update

RUN apt-get install -y python2.7
RUN apt-get install -yy python-dev
RUN apt-get install -y python-pip
RUN apt-get install -y libpq-dev
RUN apt-get install -y libgeos-dev
RUN apt-get install -y postgresql postgresql-contrib
RUN apt-get install -y pgadmin3 


RUN apt-get clean

#--------------------GENERAL FLASK DEPENDENCIES
RUN pip install boto3
RUN pip install botocore
RUN pip install enum34
RUN pip install flask
RUN pip install flask-assets
RUN pip install flask-script
RUN pip install flask-wtf
RUN pip install geoalchemy2
RUN pip install glfw
RUN pip install oauth2client
RUN pip install shapely
RUN pip install sqlalchemy
RUN pip install werkzeug
RUN pip install psycopg2
RUN pip install requests

RUN pip install flask-sqlalchemy==2.1

ADD graffiti /graffiti
#ADD graffiti/post.py /graffiti/post.py
ENV HOME /graffiti/
WORKDIR /graffiti/

#EXPOSE 5000

ENTRYPOINT ["python"]
CMD ["__init__.py"]
# add the rest of the files too