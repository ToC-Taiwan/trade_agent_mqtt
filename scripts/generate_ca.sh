#!/bin/bash

rm -rf ./configs/certs
mkdir ./configs/certs

touch ./configs/certs/openssl.cnf
cat >> ./configs/certs/openssl.cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_name

[ req_name ]
C = TW
ST = Taiwan
L = Taipei
O = TOC
OU = RD
CN = mqtt.tocraw.com
emailAddress = maochindada@email.com

[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
EOF
openssl req -nodes -new -x509 -sha256 -days 3650 -extensions v3_ca -keyout ./configs/certs/ca.key -out ./configs/certs/ca.crt -config ./configs/certs/openssl.cnf
openssl x509 -inform PEM -in ./configs/certs/ca.crt > ./configs/certs/ca_crt.pem

openssl genrsa -out ./configs/certs/server.key 2048
openssl rsa -in ./configs/certs/server.key -text > ./configs/certs/server_key.pem

openssl req -config ./configs/certs/openssl.cnf -new -sha256 -key ./configs/certs/server.key -out ./configs/certs/server.csr
openssl x509 -req -sha256 -in ./configs/certs/server.csr -CA ./configs/certs/ca.crt -CAkey ./configs/certs/ca.key -CAcreateserial -out ./configs/certs/server.crt -days 3650
openssl x509 -inform PEM -in ./configs/certs/server.crt > ./configs/certs/server_crt.pem

touch ./configs/certs/clientssl.cnf
cat >> ./configs/certs/clientssl.cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_name

[ req_name ]
C = TW
ST = Taiwan
L = Taipei
O = CLIENT
OU = RD
CN = mqtt_client
emailAddress = maochindada@email.com

[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
EOF
openssl genrsa -out ./configs/certs/client.key 2048
openssl rsa -in ./configs/certs/client.key -text > ./configs/certs/client_key.pem

openssl req -config ./configs/certs/clientssl.cnf -new -sha256 -key ./configs/certs/client.key -out ./configs/certs/client.csr
openssl x509 -req -sha256 -in ./configs/certs/client.csr -CA ./configs/certs/ca.crt -CAkey ./configs/certs/ca.key -CAcreateserial -out ./configs/certs/client.crt -days 3650
openssl x509 -inform PEM -in ./configs/certs/client.crt > ./configs/certs/client_crt.pem

openssl dhparam -out ./configs/certs/dhparam.pem 2048
mv ./.srl ./configs/certs
