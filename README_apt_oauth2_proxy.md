## apt-oauth2-proxy Configuration

A lightweight reverse proxy that injects OIDC Client Credentials tokens to proxy upstream APT repositories.

## 🔄 How It Works

```
[APT Client] → [apt-oauth2-proxy] → [Your APT Repository]
     ↓              ↓                      ↓
   apt update   OIDC Auth              Auto Token
   apt install  Auto Token Refresh      + Auto Refresh
```

**Overview of Workflow:**
1. **APT Client** requests packages
2. **apt-oauth2-proxy** authenticates with OIDC to obtain tokens
3. **Your APT Repository** receives requests with attached tokens
4. **Auto Refresh** ensures continuity when tokens expire

### 🚀 Quick Start

1) Environment Configuration
```bash
sudo cp /etc/apt-oauth2-proxy/.env.sample /etc/apt-oauth2-proxy/.env
sudo vi /etc/apt-oauth2-proxy/.env
```
For example, basic environment configuration:

```dotenv
OIDC_ISSUER=<https://issuer.example.com/>
OIDC_CLIENT_ID=<your-client-id>
OIDC_CLIENT_SECRET=<your-secret>
PROXY_BIND=0.0.0.0:8900
APT_SOURCE_URL=<https://repo.example.com/apt>
```

2) Restart Service
```bash
sudo systemctl restart apt-oauth2-proxy
```


## Advanced Environment Configuration

**Additional option settings:**
```dotenv
# APT source auto-configuration
APT_SOURCE_AUTOCONFIG=true
APT_SOURCE_DIST=stable
APT_SOURCE_COMPONENTS=main
APT_SOURCE_ARCH=amd64

# File path settings
APT_SOURCE_PATH=/etc/apt/sources.list.d/apt-oauth2-proxy.list
APT_SOURCE_DIR=/etc/apt/sources.list.d
APT_SOURCE_FILENAME=apt-oauth2-proxy.list

# Security settings
APT_SOURCE_SIGNED_BY=https://repo.example.com/apt/keyring.gpg  # HTTPS URL automatically saves to local file
APT_SOURCE_TRUSTED=false

# Local proxy settings
APT_LOCAL_SCHEME=http
APT_LOCAL_PATH_PREFIX=/repo
```

**Configuration item descriptions:**
- **OIDC**: `OIDC_ISSUER`, `OIDC_CLIENT_ID`, `OIDC_CLIENT_SECRET`
- **Proxy**: `PROXY_BIND`, `APT_SOURCE_URL`
- **APT Source**: `APT_SOURCE_DIST`, `APT_SOURCE_COMPONENTS`, `APT_SOURCE_ARCH`
- **File Management**: `APT_SOURCE_PATH`, `APT_SOURCE_DIR`, `APT_SOURCE_FILENAME`
 **Security**: `APT_SOURCE_SIGNED_BY` (Auto local save when URL specified), `APT_SOURCE_TRUSTED`
- **Local**: `APT_LOCAL_SCHEME`, `APT_LOCAL_PATH_PREFIX`

### APT Source Configuration

**Auto Configuration**: When `APT_SOURCE_AUTOCONFIG=true` is set, apt-oauth2-proxy automatically creates `/etc/apt/sources.list.d/apt-oauth2-proxy.list` file on startup. All settings must be configured through the `.env` file.

**Auto-generated source file content:**
```bash
deb [arch=<APT_SOURCE_ARCH> signed-by="/etc/apt/keyrings/$(basename <APT_SOURCE_SIGNED_BY>)"] http://<PROXY_BIND>/repo <APT_SOURCE_DIST> <APT_SOURCE_COMPONENTS>
```

**GPG Keyring Auto Download:**
- When `APT_SOURCE_SIGNED_BY` is specified as HTTPS URL, automatically downloads and saves keyring as local file
- Save location: `/etc/apt/keyrings/<filename>`
- No re-download if file already exists

**Source format explanation:**
- `deb`: Binary package repository
- `http://<PROXY_BIND>/repo`: Proxy server address (matches PROXY_BIND)
- `/repo`: APT_LOCAL_PATH_PREFIX setting value
- `<APT_SOURCE_DIST>`: APT_SOURCE_DIST setting value, distribution name (e.g., stable, testing, unstable)
- `<APT_SOURCE_COMPONENTS>`: APT_SOURCE_COMPONENTS setting value, components (e.g., main, contrib, non-free)

### Usage

- **Status Check**: `GET /`
- **APT Repository Proxy**: `GET /repo/<path>` → Proxies to `APT_SOURCE_URL + <path>` (Authorization token automatically attached)
