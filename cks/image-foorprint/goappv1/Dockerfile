FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y golang-go

COPY . .

RUN GGO_ENABLED=0 go build main.go



FROM alpine
COPY --from=0 /main .

CMD ["./main"]