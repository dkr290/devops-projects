FROM ubuntu as builder

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y golang-go

WORKDIR /build
COPY . .

RUN  go build main.go



FROM alpine
RUN addgroup -S pipeline && adduser -S  k8s-pipeline --uid 1500 -G pipeline

WORKDIR /home/k8s-pipeline
COPY --from=builder /build/main .
RUN ls -lR

CMD ["./main"]