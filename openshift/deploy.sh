#!/usr/bin/env bash

set -e -x

externalAddress="oc get service example-jgroups-site -o jsonpath="{.status.loadBalancer.ingress[0].hostname}""

loginSiteA() {
    oc login --insecure-skip-tls-verify=true \
        --server="${SERVER_A}" \
        --token="${TOKEN_A}"
}

loginSiteB() {
    oc login --insecure-skip-tls-verify=true \
        --server="${SERVER_B}" \
        --token="${TOKEN_B}"
}

replace() {
    local siteName=${1}
    local pattern=${2}
    local value=${3}
    sed "s/${pattern}/${value}/g" \
        target/deployment.${siteName}.yaml \
        > target/temp.yaml \
        && mv target/temp.yaml target/deployment.${siteName}.yaml
}

deployment() {
    pushd openshift
    local siteName=${1}
    local externalAddress=${2}
    local initialHosts=${3}
    rm target/deployment.${siteName}.yaml || true
    cp deployment.yaml target/deployment.${siteName}.yaml
    replace ${siteName} "VALUE_SITE_NAME" ${siteName}
    replace ${siteName} "VALUE_EXTERNAL_ADDRESS" ${externalAddress}
    replace ${siteName} "VALUE_SITE_INITIAL_HOSTS" ${initialHosts}
    popd
}

deploy() {
    local siteName=${1}
    oc project jgroups
    oc apply -f openshift/target/deployment.${siteName}.yaml
}

main() {
    loginSiteA
    externalAddressSiteA=`${externalAddress}`
    loginSiteB
    externalAddressSiteB=`${externalAddress}`

    initialHosts="${externalAddressSiteA}[7900],${externalAddressSiteB}[7900]"

    deployment "SiteA" ${externalAddressSiteA} ${initialHosts}
    deployment "SiteB" ${externalAddressSiteB} ${initialHosts}

    loginSiteA
    deploy "SiteA"

    loginSiteB
    deploy "SiteB"
}

main
