#! /bin/sh

# Necessary so we can run as uid 1001 (would have to inject nss_wrapper
# everywhere and don't really feel like doing so) 
oc adm policy add-scc-to-user anyuid -z gaia-ansible

# Build golang-s2i base image
oc process -f openshift/golang-s2i.yaml | oc apply -f -

# Build gaiad image
oc process -f openshift/gaiad.yaml | oc apply -f -

# Deploy
oc process -f openshift/gaia-ansible.yaml | oc apply -f -
oc start-build gaia-ansible -w

oc delete pod,service,route -l template=gaia-nodes; \
    oc delete job gaia-deploy; \
    oc apply -f openshift/deploy.yaml && \
    while ! oc logs -f jobs/gaia-deploy; do sleep 1; done