FROM golang:1.16-alpine as build
RUN sed -i 's/dl-cdn.alpinelinux.org/ftp.halifax.rwth-aachen.de/g' /etc/apk/repositories \
 && apk add bash curl git patch \
 && git clone https://github.com/jech/galene.git /galene
WORKDIR /galene
COPY .tags /tmp/
RUN git pull \
 && git checkout tags/galene-$(sed 's/,.*//' /tmp/.tags) \
 && mkdir -p /target/data /target/groups /target/recordings \
 && CGO_ENABLED=0 go build -ldflags='-s -w' \
 && cp -Rapv static galene /target

FROM scratch
COPY --from=build /target/ /
VOLUME ["/data", "/groups", "/recordings"]
ENTRYPOINT ["/galene"]
EXPOSE 8443
