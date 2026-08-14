.PHONY: commands site serve check bib clean

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

## check: check structure, spelling, and internal links
check:
	quarto check
	typos
	lychee docs --offline --no-progress

## clean: remove generated and cache files
clean:
	rm -rf .quarto _book
	find . -type f -name '*~' -delete
