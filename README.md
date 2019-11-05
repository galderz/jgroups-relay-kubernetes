# JGroups Relay Demo On Kubernetes

## Local

In one shell:

```bash
make SITE_NAME=A clean build prepare exec
```

In another shell:

```bash
make SITE_NAME=B exec
```

Two sites should join together:

```bash
Received new x-site view: [SiteB, SiteA]
```
