SHELL := /bin/bash


.PHONY: generate-packages

ARCH=amd64
CODENAME=jammy

generate-packages:
	./generate_apt_archive.sh





