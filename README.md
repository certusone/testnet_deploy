# testnet_deploy

This repo deploys a full Cosmos SDK testnet plus monitoring on a 
OpenShift Origin/okd.io Kubernetes cluster.

Requirements:

- CentOS => 7.5
- OpenShift Origin == 3.9

## Introduction

We recorded this video to guide you through the (one-click) setup of your own fully monitored Cosmos network and explain how the snippets and monitoring systems can be used.

[Watch the video here](https://www.useloom.com/share/c281221bcfb04e4798659618eb15ac88)

Also don't forget our validator knowledge base with important information about operations and monitoring.

[Knowledgebase](https://kb.certus.one/)

The `gaia_exporter`, `net_exporter` and alerting tools are built from the [chain_exporter](https://github.com/certusone/chain_exporter) repo.
Please take usage instructions from the deployment scripts and commandline output.

## Deploying an OpenShift Origin Cluster

Deploy an OpenShift Origin 3.9 cluster on CentOS 7:

    yum -y install git docker tcpdump bridge-utils vim centos-release-openshift-origin39 epel-release
    yum -y install origin origin-clients htop
    
    cat <<EOF > /etc/sysconfig/docker
    OPTIONS="--log-driver=journald --insecure-registry 172.30.0.0/16 --signature-verification=false"
    EOF
    
    systemctl enable docker
    systemctl start docker
    
    git clone https://github.com/openshift-evangelists/oc-cluster-wrapper
    
    cat <<EOF >> ~/.bash_profile
    export PATH=~/oc-cluster-wrapper:\$PATH
    export OC_CLUSTER_PUBLIC_HOSTNAME=$(hostname -f)
    export OC_CLUSTER_ROUTING_SUFFIX=apps.$(hostname --ip-address).nip.io
    EOF
    
    ~/oc-cluster-wrapper/oc-cluster completion bash > /etc/bash_completion.d/oc-cluster.bash

Re-login once you’re done to make the auto-completion work. This is a non-production deployment
of OpenShift and you can login via admin/admin. If you're running this on
a publicly reachable host, make sure to properly configure your firewall to prevent
the infamous Kubernetes Bitcoin mining botnet from assimilating your cluster:

Configure firewalld:

    yum -y install firewalld
    systemctl start firewalld
    systemctl enable firewalld
    
    firewall-cmd --permanent --new-zone admin
    firewall-cmd --permanent --add-source=your_public_ip_to_whitelist/32 --zone=admin
    firewall-cmd --permanent --add-port=8443/tcp --zone=admin
    firewall-cmd --permanent --add-port=443/tcp --zone=admin
    
    firewall-cmd --permanent --new-zone dockerc
    firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
    firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
    firewall-cmd --permanent --zone dockerc --add-port 53/udp
    firewall-cmd --permanent --zone dockerc --add-port 8053/udp
    
    firewall-cmd --permanent --add-masquerade --zone=public
    
    firewall-cmd --reload

Finally, boot up your cluster:

    oc-cluster up

You can now log into the web application using developer or admin/admin
(`https://<hostname>:8443`), or log in using the CLI:

    oc login https://<hostname>:8443

(the admin user is cluster administrator, whereas the developer user isn’t)


## Deploy our testnet

For Sentry alerts to work set the following variables:

`monitoring/exporter/alerter.yml`: Replace `<INSERT_RAVEN_DSN>` with the RAVEN_DSN URL of your (self-)hosted Sentry instance. 

If you want alerts from your alertmanager:

`monitoring/prometheus/prometheus.yml`: Modify the alertmanager config according to [the Prometheus docs](https://prometheus.io/docs/alerting/configuration/)

Login as admin:

    oc login  # admin/admin

Check out this repo:

    https://github.com/certusone/testnet_deploy
    
This deploys our testnet:

    oc new-project gaia-testnet
    ./deploy_testnet.sh
    
This deploys everything, including our monitoring stack:

    ./deploy_all.sh

Wait a few minutes - you can watch it in the "Builds" section in the UI.
