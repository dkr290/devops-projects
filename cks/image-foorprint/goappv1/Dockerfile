FROM ubuntu as builder

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y golang-go

WORKDIR /build
COPY go.mod ./
RUN go mod download && go mod tidy
COPY . .

RUN  go build main.go
RUN ls -l



FROM alpine
RUN addgroup -S pipeline && adduser -S  k8s-pipeline --uid 1500 -G pipeline

WORKDIR /home/k8s-pipeline
COPY --from=builder /build/main .
RUN ls -lR

CMD ["./main"]