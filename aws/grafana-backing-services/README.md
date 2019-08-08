# Grafana Backing Services

This module provisions the backend resources needed by [Grafana](https://grafana.com/grafana).

Requires Terraform v0.12

As of this writing, this only provisions a serverless Aurora MySQL 5.6 database.

## Security Vulnerabilities

### SSL Server Certificate Validation

Connection to the MySQL server take place via SSL, but the Aurora servers
use a distinct root certificate authority (CA) that is not in the
default trust store. Thus the MySQL client cannot validate that it is
talking to the actual MySQL server and is open to man-in-the-middle
attack. This is a security risk, but our assessment is that it is minor,
given that the network connections are all within VPCs and an attacker
who could become a man-in-the-middle would likely to be able to gain
access to all the cluster's resources through Kubernetes.

## Security To Do

### SSL Server Certificate Validation

To get the Aurora MySQL SSL connection to validate: 
1. Get the RDS CA from  https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem (expires Mar  5 09:11:31 2020 GMT)
or successor (consult current RDS documentation)
2. Save it in a `ConfigMap`
3. Mount it into the Grafana pod
4. Configure the path to it via [`ca_cert_path`](https://grafana.com/docs/installation/configuration/#ca-cert-path)
in `grafana.ini`
5. Set `ssl_mode` to `"true"` in `grafana.ini`
