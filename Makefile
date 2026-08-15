.PHONY: commands site serve check bib clean

LINKS=_extras/links.md
SRC=$(wildcard *.qmd) $(wildcard */*.qmd)

## commands: show available commands (*)
commands:
	@grep -h -E '^##' ${MAKEFILE_LIST} \
	| sed -e 's/## //g' \
	| column -t -s ':'

## site: render HTML with Quarto
site:
	quarto render
	touch docs/.nojekyll

## serve: preview the site locally
serve:
	quarto preview

## check: check structure, spelling, etc.
check: check-typos check-links check-site

check-typos:
	typos ${SRC}

check-links:
	pandoc lua bin/check-links.lua ${LINKS} ${SRC}

check-site:
	lychee docs --offline --no-progress

## clean: remove generated and cache files
clean:
	rm -rf .quarto _book
	find . -type f -name '*~' -delete
