# Keycloak Backing Services

This module provisions the backend resources needed by [Keycloak](https://www.keycloak.org/documentation.html).

As of this writing, this only provisions an Aurora MySQL 5.7 database.

## Security Vulnerabilities

### Database encryption

This module, as of this writing, provisions a database that is **not** encrypted. 
This means that database backups/snapshots are also unencrypted. The database,
and of course the backups, contain secrets that an attacker could use
to gain access to anything protected by Keycloak.
This is a security risk, though it is hard to quantify how serious it is.
While adding encryption is of course good "security in depth",
our current assessment is that encrypting the database provides little
practical additional security for the following reasons.

The database backups are protected using IAM, and any database encryption
key would also be available to someone with the right IAM credentials. As a
practical matter, anyone with access to the backups will likely also have
access to the encryption key via KMS, or be able to access the database
directly after getting the user and password from SSM, or be able to
execute commands in the Keycloak pod/container that expose the secrets. 

### SSL Server Certificate Validation

Connection to the MySQL server take place via SSL, but the RDS servers
use a distinct root certificate authority (CA) that is not in the
default trust store. Thus the MySQL client cannot validate that it is
talking to the actual MySQL server and is open to man-in-the-middle
attack. This is a security risk, but our assessment is that it is minor,
given that the network connections are all within VPCs and an attacker
who could become a man-in-the-middle would likely to be able to gain
access to all the resources protected by Keycloak by appearing to be
an authorized local service.

## Security To Do

### Database encryption

To keep the database encrypted, this module will have to be extended:
1 Create a KMS key for encrypting the database. Using the RDS default key
is not advisable since the only practical advantage of the key comes from
limiting access to it, and the default key will likey have relatively
wide access.
1. Create an IAM role for Keycloak that has access to the key. Nodes running
`kiam-server` will need to be able to assume this role.
2. Enable encryption for the database using this key.

Then the Keycloak deployment (actually `StatefulSet`) will need to be 
annotated so that `kiam` grants Keycloak access to this role. 

### SSL Server Certificate Validation

To get the RDS MySQL SSL connection to validate: 
1. Get the RDS CA from  https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem expires (Mar  5 09:11:31 2020 GMT)
or successor (consult current RDS documentation)
2. Import it into a Java KeyStore (JKS) 
    *  Run`keytool -importcert -alias MySQLCACert -file ca.pem  -keystore truststore -storepass mypassword` in a Keycloak
    container in order to be sure to get a compatible version of the Java SDK `keytool`
3. Copy the KeyStore into a secret
4. Mount the Secret
5. Set [`JDBC_PARAMS` environment variable](https://github.com/jboss-dockerfiles/keycloak/blob/119fb1f61a477ec217ba71c18c3a71a10e8d5575/server/tools/cli/databases/mysql/change-database.cli#L2 )
   to `?clientCertificateKeyStoreUrl=file:///path-to-keystore&clientCertificateKeyStorePassword=mypassword`
6. Note that it would seem to be more appropriate to set to 
`?trustCertificateKeyStoreUrl=file:///path-to-keystore&trustCertificateKeyStorePassword=mypassword`
 but the [documentation](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-using-ssl.html) 
 [consistently](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-configuration-properties.html)
 says to use the `clientCertificate*` stuff for verifying the server.
