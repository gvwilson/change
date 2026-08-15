.PHONY: commands site serve check bib clean

BIB=bibliography/references.bib
LUA=pandoc lua
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
check: check-bib check-links check-site check-typos

## check-bib: check bibliography
check-bib:
	${LUA} bin/check-bib.lua ${BIB} ${SRC}

## check-links: check Markdown links
check-links:
	${LUA} bin/check-links.lua ${LINKS} ${SRC}

## check-site: check HTML links
check-site:
	lychee docs --offline --no-progress

## check-typos: check spelling
check-typos:
	typos ${SRC}

## clean: remove generated and cache files
clean:
	rm -rf .quarto _book
	find . -type f -name '*~' -delete
