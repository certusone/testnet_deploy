#! /bin/sh
cd $(dirname $0)

oc delete configmap grafana-datasources
oc delete configmap grafana-dashboards
oc delete configmap grafana-dashboards-prov

oc create configmap grafana-datasources --from-file=datastores/
oc create configmap grafana-dashboards --from-file=dashboards/
oc create configmap grafana-dashboards-prov --from-file=dashboards-prov/
oc process -f grafana.yml | oc apply -f -