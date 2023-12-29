# Dockerfile to run aws cdk commands
# References
# - AWS CLI https://levelup.gitconnected.com/how-to-create-a-simple-docker-image-with-aws-cli-and-serverless-installed-d1cc2901946
FROM alpine:3.19.0
# Install packages
RUN apk update && apk add --update --no-cache \
    git \
    bash \
    curl \
    openssh \
    python3 \
    py3-pip \
    py-cryptography \
    wget \
    curl \
    nodejs \
    npm
RUN apk --no-cache add --virtual builds-deps build-base python3

RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin


ENV PATH="/usr/local/go/bin:${PATH}"
# Update NPM
RUN npm install --unsafe-perm=true -g now
RUN npm update -g
# Install AWSCLI
RUN pip install --upgrade pip --break-system-packages && \
    pip install --upgrade awscli --break-system-packages
# Install cdk
RUN npm install -g aws-cdk
RUN cdk --version
WORKDIR /app
ENTRYPOINT []


#to run
# docker build -t aws-cdk-docker .
# docker run --name cdk --rm -itd -v `pwd`:/app -v ${HOME}/.aws/credentials:/root/.aws/credentials:ro -v ${HOME}/.aws/config:/root/.aws/config:ro  aws-cdk-docker bash
# docker exec -it 79b5 bash 
# docker exec -it cdk bash