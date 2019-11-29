# JGroups Relay Demo On Kubernetes

## Requirements

* OpenShift 4.1 client library added to `PATH`.
You can download it from
[here](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/).

## OpenShift on AWS

Create a `.openshift` file in `openshift` folder,
that contains credentials to talk to OpenShift clusters:

```bash
export SERVER_A=https://api.infinispan.devcluster.openshift.com:6443
export USERNAME_A=kubeadmin
export PASSWORD_A=12345
export SERVER_B=https://api.infinispan.devcluster.openshift.com:6443
export USERNAME_B=kubeadmin
export PASSWORD_B=12345
```

Next, source the file so that the environment variables get applied in your shell:

```bash
cd openshift
source .openshift
```

With the credentials set, generate a set of session tokens to interacting with OpenShift.
This session tokens will be set as environment variables and will be used by scripts.
Note that generating session tokens involves remote calls and might take some time:

```bash
cd openshift
source export-tokens.sh
```

Next, build the code and docker image:

```bash
make build image
```

Push the image so that it can be deployed on OpenShift:

```bash
make push
```

To establish a JGroups relay channel between OpenShift clusters,
a load balancer Service is required that exposes a external address.
Create the load balancer service in both clusters by calling the following command:

```bash
make deploy-loadbalancer
```

**NOTE**: This command might take a while,
since it requires both load balancer services to get assigned an external host name,
and it also waits until each host name resolves to an IP address.

In the final step, deploy the JGroups relay demo.
This demo dynamically uses information from the load balancers
to set several JGroups configuration parameters:

```bash
make deploy
```

**NOTE**: With the load balancer in place,
you can make as many changes to JGroups demo and image,
without the need to re-spin new load balancers.
