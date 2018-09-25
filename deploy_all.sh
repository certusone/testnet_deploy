#! /bin/sh

./deploy_testnet.sh

./monitoring/exporter/deploy.sh
./monitoring/prometheus/deploy.sh
./monitoring/grafana/deploy.sh