# Contributing

Contributions are very welcome;
please contact us [by email][email] or by filing an issue in [our repository][repo].
All contributors must abide by our Code of Conduct.

## Setup and Operation

-   Install [uv][uv].
-   Create a virtual environment: `uv venv`.
-   Activate it: `source .venv/bin/activate`.
-   Install dependencies: `uv sync`.
-   Run `make` on its own to see a list of common commands.

| make task | effect                            |
| --------- | ----------------------------------|
| build     | render HTML pages                 |
| clean     | clean up                          |
| commands  | show available commands (default) |
| links     | check links in published site     |
| lint      | check structure and content       |
| serve     | serve generated HTML              |
| spelling  | check for unknown words           |
| untab     | remove tabs in Markdown files     |

## Structure

-   Lessons are in `slug` directories
    -   `slug` is short mnemonic
    -   Each lesson must have an `index.md` file containing its content
    -   And may also have a `slides.md` file with [Shower][shower] slides
-   Use `@/some/path/` for internal links
    -   The leading `@` is translated into a relative reference to the project root
-   The Markdown link definitions in `extras/links.md` are appended to all Markdown files
    -   This helps ensure consistent link URLs across pages
-   The home page for the site is generated from `README.md`
    -   The navigation menus for lessons and appendices are generated from
        the `lessons` and `appendices` `div` elements in `README.md`
-   Diagrams should be SVG files created with [draw.io][draw-io]
-   `bibliography/index.md` has the bibliography as a definition list
    -   Citation keys have IDs for linking
    -   Use an inline HTML link `b:key` in files to create links
-   `glossary/index.md` has the glossary as definition list
    -   Reference keys have IDs for linking
    -   Use an inline HTML link `g:key` in files to create links
-   The `static` directory contains CSS and JavaScript files
-   The `templates` directory contains [Jinja][jinja] templates used to generate HTML
    -   `page.html` is used for website pages
    -   `slides.html` is used for slideshows

## FAQ

Do you need help?
:   Yes—please see the issues in [our repository][repo].

What sort of feedback would be useful?
:   Everything is welcome,
    from pointing out mistakes to suggestions for better explanations.

Can I add a new section?
:   Possibly, but please [reach out][email] before doing so.

Why is this material free?
:   Because if we all give a little, we all get a lot.

[draw-io]: https://www.drawio.com/
[email]: mailto:gvwilson@third-bit.com
[jinja]: https://jinja.palletsprojects.com/
[repo]: https://github.com/gvwilson/change
[shower]: https://shwr.me/
[uv]: https://github.com/astral-sh/uv
