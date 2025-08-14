## APT 저장소 사용 안내 (사용자용)

### 전제 조건
- Ubuntu 22.04 LTS (jammy), amd64

### HTTP/HTTPS 원격 저장소로 사용하기
1) 키링 경로 설정 및 공개키 등록
```bash
KEYRING=/usr/share/keyrings/apple-apt-archive-keyring.gpg

sudo curl -fsSL "http://fantajeon.github.io/apple-apt-repo/ubuntu/public_key.asc" \
  | sudo gpg --dearmor -o "$KEYRING"
```

2) 소스 리스트 추가
```bash
LIST=/etc/apt/sources.list.d/apple-apt.list
echo "deb [arch=amd64 signed-by=$KEYRING] http://fantajeon.github.io/apple-apt-repo/ubuntu jammy main" \
  | sudo tee "$LIST"
```

3) 갱신 및 설치
```bash
sudo apt update
sudo apt install apt-oauth2-proxy
```

2) 갱신 및 설치
```bash
sudo apt update
sudo apt install apt-oauth2-proxy
```

### 검증
```bash
apt-cache policy apt-oauth2-proxy
```

### 제거(정리)
원격 저장소 사용 시 키/소스 제거:
```bash
REPO_ID=apple-apt
LIST=/etc/apt/sources.list.d/${REPO_ID}.list
KEYRING=/usr/share/keyrings/${REPO_ID}-archive-keyring.gpg
sudo rm -f "$LIST"
sudo rm -f "$KEYRING"
sudo apt update
```
