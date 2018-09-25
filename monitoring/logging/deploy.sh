#! /bin/sh
cd $(dirname $0)

oc process -f kafka.yml | oc apply -f -

oc apply -f fluentd.yml -n kube-system
oc adm policy add-scc-to-user privileged -z fluentd -n kube-system
oc patch ds fluentd -n kube-system -p "spec:
  template:
    spec:
      containers:
      - name: fluentd
        securityContext:
          privileged: true"
oc delete pod --namespace kube-system -l "k8s-app = fluentd-logging"

