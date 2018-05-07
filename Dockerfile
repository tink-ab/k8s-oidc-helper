FROM golang:1.10-alpine as builder
RUN apk add -U ca-certificates
WORKDIR /go/src/github.com/tink-ab/k8s-oidc-helper
ADD . .
RUN go install -ldflags '-w'

FROM alpine:latest
RUN apk add -U ca-certificates
COPY --from=builder /go/bin/k8s-oidc-helper /bin/k8s-oidc-helper
ENTRYPOINT ["/bin/k8s-oidc-helper"]
