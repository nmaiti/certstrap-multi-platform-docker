# Dockerfile for squareup/certstrap
#
# To build this image:
#     docker build -t squareup/certstrap .
#
# To run certstrap from the image (for example):
#     docker run --rm squareup/certstrap --version

FROM golang:1.17-alpine as build

MAINTAINER Nabendu Maiti "nbmaiti83@gmail.com"

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# Install build dependencies for docker-gen
RUN apk --no-cache add \
        curl \
        gcc \
        git \
        make \
        musl-dev ca-certificates


RUN cd /go/src
RUN ls -ltr
RUN git clone https://github.com/square/certstrap.git
RUN cd certstrap
WORKDIR  /go/certstrap
RUN case "$TARGETVARIANT" in  \
            v7) export GOARM='6' ;; \
            v6) export GOARM='5' ;; \
			*) echo "nothing here" ;;\
    esac

#COPY go.mod .
#COPY go.sum .

# Download dependencies
#RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go mod download
#GOARCH=amd64 GOOS=linux go build -ldflags "-X main.release=$BUILD_TAG" -o bin/certstrap
# Copy source
#COPY . .

# Build
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /usr/bin/certstrap

# Create a multi-stage build with the binary
FROM alpine

COPY --from=build /usr/bin/certstrap /usr/bin/certstrap

ENTRYPOINT ["/usr/bin/certstrap"]
