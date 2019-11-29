SITE_NAME := "<empty>"

INITIAL_HOSTS := "127.0.0.1[7850],127.0.0.1[7950]"

clean:
	mvn clean

build:
	mvn dependency:copy-dependencies package

image:
	docker build -t galderz/jgroups-relay-kubernetes .

push:
	docker push galderz/jgroups-relay-kubernetes

deploy-loadbalancer:
	$(call login-server,A)
	$(call deploy-loadbalancer)
	$(call login-server,B)
	$(call deploy-loadbalancer)

define deploy-loadbalancer
oc new-project jgroups || true
oc apply -f ./openshift/loadbalancer.yaml
./openshift/wait-for-loadbalancer.sh example-jgroups-site
endef

define login-server
oc login --insecure-skip-tls-verify=true \
    --server=${SERVER_${1}} \
    --token=${TOKEN_${1}}
endef

undeploy-loadbalancer:
	$(call login-server,A)
	$(call undeploy-loadbalancer)
	$(call login-server,B)
	$(call undeploy-loadbalancer)

define undeploy-loadbalancer
oc project jgroups
oc delete service example-jgroups-site
endef

deploy:
	./openshift/deploy.sh

undeploy:
	$(call login-server,A)
	$(call undeploy)
	$(call login-server,B)
	$(call undeploy)

define undeploy
oc delete deployment example-jgroups
endef
