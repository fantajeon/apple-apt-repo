## APT repository quickstart (for users)

### Prerequisites
- Ubuntu 22.04 LTS (jammy), amd64

### Use over HTTP/HTTPS
1) Install the repository public key (keyring)
```bash
KEYRING=/usr/share/keyrings/apple-apt-archive-keyring.gpg

sudo curl -fsSL "http://fantajeon.github.io/apple-apt-repo/ubuntu/public_key.asc" \
  | sudo gpg --dearmor -o "$KEYRING"
```

2) Add an APT source list entry
```bash
LIST=/etc/apt/sources.list.d/apple-apt.list
echo "deb [arch=amd64 signed-by=$KEYRING] http://fantajeon.github.io/apple-apt-repo/ubuntu jammy main" \
  | sudo tee "$LIST"
```

3) Update and install
```bash
sudo apt update
sudo apt install apt-oauth2-proxy
```

Update and install (if needed again)
```bash
sudo apt update
sudo apt install apt-oauth2-proxy
```

### Verify
```bash
apt-cache policy apt-oauth2-proxy
```

### Remove (cleanup)
Remove key and source list:
```bash
REPO_ID=apple-apt
LIST=/etc/apt/sources.list.d/${REPO_ID}.list
KEYRING=/usr/share/keyrings/${REPO_ID}-archive-keyring.gpg
sudo rm -f "$LIST"
sudo rm -f "$KEYRING"
sudo apt update
```

## Detailed Configuration Guide

For detailed configuration of `apt-oauth2-proxy`, see the [Configuration Guide](README_apt_oauth2_proxy.md).

### Key Configuration Items
- OAuth2 Authentication Setup
- Proxy Server Configuration
- Security Settings
- Monitoring and Logging
