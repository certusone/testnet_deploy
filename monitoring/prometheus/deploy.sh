#! /bin/bash
cd $(dirname $0)

# Start blackbox exporter
oc apply -f blackbox_exporter.yml -n kube-system
oc adm policy add-scc-to-user -z prometheus-blackbox-exporter -n kube-system privileged hostaccess

# Start node exporter
oc apply -f node_exporter.yml -n kube-system
oc adm policy add-scc-to-user -z prometheus-node-exporter -n kube-system hostaccess

oc process -f prometheus.yml | oc apply -f -