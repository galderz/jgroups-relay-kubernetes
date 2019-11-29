#!/usr/bin/env bash

set -x

external_hostname=""
while [ -z $external_hostname ]; do
    echo "Waiting for load balancer host name..."
    external_hostname=$(kubectl get service $1 --template="{{range .status.loadBalancer.ingress}}{{.hostname}}{{end}}")
    [ -z "$external_hostname" ] && sleep 10
done
echo 'Load balancer host name ready:' && echo $external_hostname

ip=$(host $external_hostname > /dev/null)
ip_success=$?
while [ $ip_success -ne 0 ]; do
    echo "Waiting for load balancer host name to resolve..."
    sleep 10
    ip=$(host $external_hostname > /dev/null)
    ip_success=$?
done
echo 'Load balancer host name resolves'
