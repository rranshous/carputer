FROM ubuntu:xenial

RUN apt update
RUN apt install -y ffmpeg gpsd-clients

ENV PATH="/app/bin:${PATH}"

COPY . /app
WORKDIR /app/bin

VOLUME ["/data"]
