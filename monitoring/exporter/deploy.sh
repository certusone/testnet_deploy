#! /bin/sh
cd $(dirname $0)

oc process -f postgres.yml | oc apply -f -
oc process -f lcd.yml | oc apply -f -
oc process -f exporter.yml | oc apply -f -
oc process -f alerter.yml | oc apply -f -
oc process -f net_exporter.yml | oc apply -f -