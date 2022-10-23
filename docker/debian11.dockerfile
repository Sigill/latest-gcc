FROM debian:11

RUN apt-get update && apt-get -y install build-essential ccache cmake ninja-build
RUN apt-get -y install libelf-dev libmpfr-dev libmpc-dev flex texinfo
