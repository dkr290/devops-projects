FROM alpine

RUN apt-get update && apt-get install -y golang-go
RUN apk update
WORKDIR /build
COPY go.mod ./
RUN go mod download && go mod tidy
COPY . .

RUN  go build main.go

CMD ["./main"]