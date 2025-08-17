SHELL := /bin/bash


.PHONY: generate-packages

ARCH=amd64
CODENAME=jammy

install-deps:
	sudo apt-get install -y pandoc

generate-packages:
	./generate_apt_archive.sh


generate-html:
	# Convert README.md to index.html
	pandoc README.md -o index.html --standalone --css=style.css --metadata title="Apple APT repository"
	# Convert Markdown files to HTML, excluding files listed in .exclude_md
	@for file in *.md; do \
		if [ -f "$$file" ]; then \
			if [ -f .exclude_md ] && grep -Fxq "$$file" .exclude_md; then \
				echo "Skipped $$file (excluded)"; \
			else \
				pandoc "$$file" -o "$$file.html" --standalone --css=style.css; \
				echo "Converted $$file to $$file.html"; \
			fi; \
		fi; \
		done
	# Update only specified HTML files: replace .md links with .html using .link_update_files
	@if [ -f .link_update_files ]; then \
		while IFS= read -r file; do \
			if [ -n "$$file" ] && [ -f "$$file" ]; then \
				sed -i 's/\.md"/\.html"/g' "$$file"; \
				echo "Updated links in $$file"; \
			fi; \
		done < .link_update_files; \
	fi

