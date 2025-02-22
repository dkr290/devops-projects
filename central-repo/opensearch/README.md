# Introduction

Opensearch deployment with helm chars in opensearch namespace with master data and client nodes

# Getting Started

1. First create the certificates as following
   k create secret generic opensearch-certificates --from-file=node-cert.pem --from-file=node-key.pem --from-file=root-ca.pem -n opensearch
   This will be done with the pipeline

1. Installation process
1. Software dependencies
1. Latest releases
1. API references

# Build and Test

TODO: Describe and show how to build your code and run the tests.
