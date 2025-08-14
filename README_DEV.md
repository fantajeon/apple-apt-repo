# apt archive

GitHub Pages 또는 임의의 정적 서버로 APT 저장소를 배포하는 예시입니다.

### 디렉터리 레이아웃(표준)
- `ubuntu/`가 저장소 루트입니다(여기가 URL 베이스가 됨)
  - `dists/jammy/main/binary-amd64/Packages(.gz)`
  - `dists/jammy/Release`, `dists/jammy/InRelease`, `dists/jammy/Release.gpg`
  - `pool/main/<패키지들>.deb`
  - `public_key.asc` (선택: 공개키 제공용)

### 사전 준비물
- `apt-ftparchive` (패키지 인덱스/Release 생성)
- `gpg` (Release 서명)

### 구성 파일 생성 및 인덱스/서명 생성
- Makefile이 표준 컴포넌트/아키텍처를 설정합니다.
  - `make generate-config` → `apt-ftparchive.conf` 생성
  - `make generate-packages` → `generate_apt_archive.sh` 실행(패키지 인덱스, Release, 서명 생성)

환경변수로 덮어쓰기 가능:
- `REPO_ROOT` (기본: `$(pwd)/ubuntu`)
- `DIST_CODENAME` (기본: `jammy`)
- `ARCH` (기본: `amd64`)
- `GPG_KEY_ID` (기본: 스크립트 내 기본값)
- `CONFIG_FILE` (기본: `$(pwd)/apt-ftparchive.conf`)

예)
```bash
make generate-packages
# 또는
DIST_CODENAME=jammy ARCH=amd64 make generate-packages
```

생성 후 실제 파일은 다음에 위치합니다.
- `ubuntu/dists/jammy/main/binary-amd64/Packages` 및 `Packages.gz`
- `ubuntu/dists/jammy/Release`, `InRelease`, `Release.gpg`

### 정적 서버로 서빙하기
저장소 루트인 `ubuntu/`를 웹서버의 루트 URL 하위로 노출하세요.
예: `http://<host>/ubuntu/`에 `dists/`, `pool/`가 보여야 합니다.

간단 테스트(임시):
```bash
cd ubuntu
python3 -m http.server 8000
# http://127.0.0.1:8000 에서 접근 가능
```

### 클라이언트 설정(`/etc/apt/sources.list.d/*.list`)
공개키 설치(HTTP로 제공하는 경우 권장):
```bash
sudo curl -fsSL http://<host>/ubuntu/public_key.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/hyeokjune-archive-keyring.gpg
```

HTTP/HTTPS로 사용 시 예시:
```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/hyeokjune-archive-keyring.gpg] http://<host>/ubuntu jammy main" \
  | sudo tee /etc/apt/sources.list.d/hyeokjune-archive.list
```

로컬 파일 시스템에서 바로 사용 시 예시:
```bash
echo "deb [arch=amd64 trusted=yes] file:/home/furiosa/hyeokjune/apt-repo/ubuntu jammy main" \
  | sudo tee /etc/apt/sources.list.d/hyeokjune-archive.list
```

설정 반영:
```bash
sudo apt update
```

### 참고
- `generate_apt_archive.sh`는 표준 경로 `dists/<codename>/main/binary-<arch>/`에 `Packages(.gz)`를 생성하며,
  `apt-ftparchive.conf`를 사용해 `Release`에 `Components: main`, `Architectures: amd64` 등을 정확히 기록합니다.
- `deb ... jammy main` 항목은 위 레이아웃을 전제로 합니다. `main/binary-<arch>` 단계가 반드시 필요합니다.

### GPG 서명 옵션
- 환경변수
  - `GPG_SIGN=true|false`: 서명 수행 여부(기본: true)
  - `GPG_KEY_ID`: 서명에 사용할 키 ID
  - `GPG_PASSPHRASE`: 패스프레이즈(환경변수 입력)
  - `GPG_PASSPHRASE_FILE`: 패스프레이즈 파일 경로(`--passphrase-file` 우선 적용). 기본값: `.secrets/gpg_passphrase`

예시
```bash
# .secrets/ 기본 경로 사용(권장: 리포에 커밋되지 않음)
mkdir -p .secrets
echo -n 'my-secret-passphrase' > .secrets/gpg_passphrase
chmod 600 .secrets/gpg_passphrase
GPG_SIGN=true GPG_KEY_ID=<KEYID> make generate-packages

# 임의의 경로를 직접 지정하고 싶은 경우
GPG_SIGN=true GPG_KEY_ID=<KEYID> GPG_PASSPHRASE_FILE=/path/to/gpg.pass make generate-packages

# 환경변수 직접 지정(비권장: 프로세스 목록/로그 노출 위험)
GPG_SIGN=true GPG_KEY_ID=<KEYID> GPG_PASSPHRASE='my-secret-passphrase' make generate-packages
```