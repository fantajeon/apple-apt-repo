#!/bin/bash

set -ex

REPO_ROOT="${REPO_ROOT:-$(pwd)/ubuntu}"
DIST_CODENAME="${DIST_CODENAME:-jammy}"
ARCH="${ARCH:-amd64}"
GPG_KEY_ID="${GPG_KEY_ID:-0A610B2368A29622A7F4FD3AA887F3BAF5C4FB6C}"
GPG_SIGN="${GPG_SIGN:-true}"
GPG_PASSPHRASE="${GPG_PASSPHRASE:-}"
GPG_PASSPHRASE_FILE="${GPG_PASSPHRASE_FILE:-".secrets/gpg_passphrase"}"

CODENAME_DIST_PATH="$REPO_ROOT/dists/$DIST_CODENAME"
ARCH_DIST_PATH="$CODENAME_DIST_PATH/main/binary-$ARCH"
CONFIG_FILE="${CONFIG_FILE:-$(pwd)/apt-ftparchive.conf}"

function create_dirs() {
    mkdir -p $CODENAME_DIST_PATH
    mkdir -p $ARCH_DIST_PATH
}

function create_config() {
    if [ -f "$CONFIG_FILE" ]; then
        return
    fi
    cat > "$CONFIG_FILE" <<EOF
APT::FTPArchive::Release::Origin "Hyeokjune's APT Repo";
APT::FTPArchive::Release::Label "Hyeokjune's Packages";
APT::FTPArchive::Release::Suite "$DIST_CODENAME";
APT::FTPArchive::Release::Codename "$DIST_CODENAME";
APT::FTPArchive::Release::Architectures "$ARCH";
APT::FTPArchive::Release::Components "main";
EOF
}

function generate_packages() {
    PACKAGES_PATH="$ARCH_DIST_PATH/Packages"
    pushd $REPO_ROOT
    apt-ftparchive packages pool/main/ > "$PACKAGES_PATH"
    gzip -9 -c "$PACKAGES_PATH" > "$PACKAGES_PATH.gz"
}

function generate_release() {
    apt-ftparchive -c "$CONFIG_FILE" release $CODENAME_DIST_PATH > $CODENAME_DIST_PATH/Release
}

function sign_release() {
    if [ "$GPG_SIGN" != "true" ]; then
        echo "GPG_SIGN=false: 서명을 건너뜁니다 (Release.gpg / InRelease 미생성)."
        return
    fi
    # 민감정보가 xtrace에 노출되지 않도록 비활성화
    set +x
    local gpg_flags=(--batch --yes --pinentry-mode=loopback -u "$GPG_KEY_ID")
    if [ -n "$GPG_PASSPHRASE_FILE" ] && [ -f "$GPG_PASSPHRASE_FILE" ]; then
        gpg_flags+=(--passphrase-file "$GPG_PASSPHRASE_FILE")
    elif [ -n "$GPG_PASSPHRASE" ]; then
        gpg_flags+=(--passphrase "$GPG_PASSPHRASE")
    fi
    gpg "${gpg_flags[@]}" -abs -o "$CODENAME_DIST_PATH/Release.gpg" "$CODENAME_DIST_PATH/Release"
    gpg "${gpg_flags[@]}" --clearsign -o "$CODENAME_DIST_PATH/InRelease" "$CODENAME_DIST_PATH/Release"
    # 다시 xtrace 활성화
    set -x
}

create_dirs
create_config
generate_packages
generate_release
sign_release








