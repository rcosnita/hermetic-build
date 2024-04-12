#!/usr/bin/env bash
set -eox pipefail

/usr/sbin/sshd
mkdir tools || true
cd tools
wget -O kafka.tgz https://archive.apache.org/dist/kafka/3.7.0/kafka_2.13-3.7.0.tgz
tar xzvf kafka.tgz
bash