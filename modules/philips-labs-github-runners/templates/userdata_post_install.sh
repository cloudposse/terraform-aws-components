
echo "Installing Custom Packages..."
yum install -y make

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install `gh` CLI
type -p yum-config-manager >/dev/null || sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo yum install -y gh

# Install nodejs
sudo yum install -y nodejs-1:18.18.2-1.amzn2023.0.1
