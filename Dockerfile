FROM python:2.7
EXPOSE 5000

# install dependencies
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

ADD /server/graffiti/ /docker/
WORKDIR /docker

CMD ["python", "__init__.py"]
