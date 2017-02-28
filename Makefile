NAME=server/graffiti
VERSION=`git describe --always`
CORE_VERSION=HEAD

all: prepare build

build:
	docker build -t a2 .
