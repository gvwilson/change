all: commands

## commands: show available commands (*)
commands:
	@grep -h -E '^##' ${MAKEFILE_LIST} \
	| sed -e 's/## //g' \
	| column -t -s ':'

## site: build HTML
site:
	@mccole build --src . --dst docs
	@touch docs/.nojekyll

## clean: clean up
clean:
	@find . -type f -name '*~' -exec rm {} \;
	@find . -type d -name __pycache__ | xargs rm -r
	@find . -type d -name .ruff_cache | xargs rm -r

## check: check code and project
check:
	@mccole check --src . --dst docs

## serve: serve generated HTML
serve:
	@python -m http.server -d docs $(PORT)
