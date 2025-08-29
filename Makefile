# Runnable tasks.

SLUG=change

all: commands

HTML_IGNORES = 'Attribute "x-' 'Attribute "@click' 'Attribute "file"'

## build: build HTML
build:
	mccole build --links extras/links.txt
	@touch docs/.nojekyll

## commands: show available commands (*)
commands:
	@grep -h -E '^##' ${MAKEFILE_LIST} \
	| sed -e 's/## //g' \
	| column -t -s ':'

## clean: clean up
clean:
	@find . -type f -name '*~' -exec rm {} \;
	@find . -type d -name __pycache__ | xargs rm -r
	@find . -type d -name .ruff_cache | xargs rm -r

## links: check links in published site
links:
	linkchecker -F text https://gvwilson.github.io/${SLUG}/

## lint: check code and project
lint:
	@mccole lint --html --links extras/links.txt

## serve: serve generated HTML
serve:
	@python -m http.server -d docs $(PORT)

## spelling: check for unknown words
spelling:
	@cat *.md */*.md | aspell list | sort | uniq | diff - extras/words.txt

## untab: remove tabs in Markdown files
untab:
	@find . -name '*.md' -type f -exec sh -c 'expand -t 8 "$$1" > "$$1.tmp" && mv "$$1.tmp" "$$1"' _ {} \;
