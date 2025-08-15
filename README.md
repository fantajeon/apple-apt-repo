## APT repository quickstart (for users)

### Prerequisites
- Ubuntu 22.04 LTS (jammy), amd64

### Use over HTTP/HTTPS
1) Configure APT keyring and source list
```bash
REPO_ID=apple-apt
ARCH=amd64
CODENAME=jammy
KEYRING=/etc/apt/keyrings/${REPO_ID}-archive-keyring.gpg
LIST=/etc/apt/sources.list.d/${REPO_ID}.list

# Install repository public key (idempotent)
sudo curl -fsSL "http://fantajeon.github.io/apple-apt-repo/ubuntu/public_key.asc" \
  | sudo gpg --dearmor -o "$KEYRING"
sudo chmod 0644 "$KEYRING"

# Add APT source list entry
echo "deb [arch=${ARCH} signed-by=${KEYRING}] http://fantajeon.github.io/apple-apt-repo/ubuntu ${CODENAME} main" \
  | sudo tee "$LIST"
```

2) Update and install
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
KEYRING=/etc/apt/keyrings/${REPO_ID}-archive-keyring.gpg
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
