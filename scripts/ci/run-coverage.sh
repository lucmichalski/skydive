#!/bin/bash

set -v

if [ ! -d "${GOPATH}/src/github.com/skydive-project/skydive-ci" ]
then
	echo "Could not find ${GOPATH}/src/github.com/skydive-project/skydive-ci"
	exit 1
fi

dir="$(dirname "$0")"

go get -f -u github.com/axw/gocov/gocov
go get -f -u github.com/mattn/goveralls
go get -f -u golang.org/x/tools/cmd/cover

sudo iptables -F
sudo iptables -P FORWARD ACCEPT
for i in $(find /proc/sys/net/bridge/ -type f) ; do echo 0 | sudo tee $i ; done

set -e

cd ${GOPATH}/src/github.com/skydive-project/skydive

export ARGS="-graph.output ascii"
./coverage.sh --no-functionals --no-scale
sudo ../skydive-ci/scripts/cleanup.sh snapshot
sudo ../skydive-ci/scripts/cleanup.sh cleanup
./coverage.sh --no-units --no-scale
sudo ../skydive-ci/scripts/cleanup.sh snapshot
sudo ../skydive-ci/scripts/cleanup.sh cleanup
./coverage.sh --no-units --no-scale --orientdb
sudo ../skydive-ci/scripts/cleanup.sh snapshot
sudo ../skydive-ci/scripts/cleanup.sh cleanup
./coverage.sh --no-units --no-functionals --coveralls
