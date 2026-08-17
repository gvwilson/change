.PHONY: commands site serve check bib clean

BIB=bibliography/references.bib
BIN=_bin
DOCS=docs
LUA=pandoc lua
LINKS=_extras/links.md
GLOSSARY=glossary/index.qmd
MD_SRC=$(wildcard *.qmd) $(wildcard */*.qmd)
QUARTO=quarto
SLIDES_SRC=$(wildcard slides.qmd) $(wildcard */slides.qmd)
SLIDES_DST=$(patsubst %.qmd,${DOCS}/%.html,${SLIDES_SRC})
SLIDES_FLAGS=-V theme=simple -f markdown -t revealjs -s --citeproc --bibliography=${BIB} --csl=_extras/slides.csl

## commands: show available commands (*)
commands:
	@grep -h -E '^##' ${MAKEFILE_LIST} \
	| sed -e 's/## //g' \
	| column -t -s ':'

## site: render HTML with Quarto
site:
	${QUARTO} render
	touch ${DOCS}/.nojekyll

## serve: preview the site locally
serve:
	${QUARTO} preview

## publish: publish the site
publish:
	${LUA} ${BIN}/publish.lua docs ${OUT} ${EXTRA}

## slides: rebuild just the slides
slides: ${SLIDES_DST}

${DOCS}/%.html: %.qmd
	mkdir -p $(@D)
	pandoc $< ${SLIDES_FLAGS} -o $@

## check: check structure, spelling, etc.
check: check-bib check-links check-glossary check-typos

## check-bib: check bibliography
check-bib:
	${LUA} ${BIN}/check-bib.lua ${BIB} ${MD_SRC}

## check-links: check Markdown links
check-links:
	${LUA} ${BIN}/check-links.lua ${LINKS} ${MD_SRC}

## check-glossary: check glossary references
check-glossary:
	${LUA} ${BIN}/check-glossary.lua ${GLOSSARY} ${MD_SRC}

## check-typos: check spelling
check-typos:
	typos -c _misc/typos.toml ${MD_SRC}

## clean: remove generated and cache files
clean:
	rm -rf .quarto _book
	find . -type f -name '*~' -delete
