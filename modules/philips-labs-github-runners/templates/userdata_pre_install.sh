# From https://github.com/aws-observability/aws-otel-test-framework/pull/1425/files
## Fixes: Error loading Python lib '/tmp/_MEIaR70C0/libpython3.7m.so.1.0': dlopen: libcrypt.so.1: cannot open shared object file: No such file or directory

echo "Custom Pre-Install Script"
sudo yum update -y
sudo yum install -y libxcrypt-compat
sudo yum install -y docker
sudo ln -s /usr/lib/libcrypt.so /usr/lib/libcrypt.so.1
