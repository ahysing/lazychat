ARG REGISTRY=
FROM ${REGISTRY}golang:1.14.9-alpine3.12 AS builder
ARG WORKDIR=/work
ENV BINARY lazy-chat
ENV CMD lazychat
WORKDIR ${WORKDIR}

COPY go.mod go.mod
COPY go.sum go.sum
COPY cmd cmd
COPY pkg pkg
RUN mkdir -p ${WORKDIR}/build
COPY web ${WORKDIR}/build/web
COPY run.sh ${WORKDIR}/build/run.sh


RUN mkdir ${WORKDIR}/gopath
ENV GOPATH ${WORKDIR}/gopath
RUN GOOS=linux GOARCH=amd64 go install ${WORKDIR}/cmd/${CMD}
RUN GOOS=linux GOARCH=amd64 go build -o ${WORKDIR}/build/${BINARY} ./cmd/${CMD}


FROM alpine:3.12

WORKDIR /usr/bin

COPY --from=builder /work/build /usr/bin
COPY --from=builder /work/gopath /usr/bin/gopath

RUN addgroup appuser ; \
    adduser -S -D -H -h /usr/bin appuser appuser

# read only access
RUN chmod 500 /usr/bin/web/* ; chown appuser:appuser /usr/bin/web/*
RUN chmod 500 -R /usr/bin/web ; chown appuser:appuser /usr/bin/web
# owner can execute and read only access
RUN chmod 500 /usr/bin/lazy-chat ; chown appuser:appuser /usr/bin/lazy-chat

USER appuser

ENV GOPATH /usr/bin/gopath

EXPOSE 8080
ENTRYPOINT [ "/usr/bin/lazy-chat" ]
