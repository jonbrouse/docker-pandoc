# Pandoc

[Pandoc](https://pandoc.org/) an convert documents in (several dialects of) Markdown, reStructuredText, textile, HTML, DocBook, LaTeX, MediaWiki markup, TWiki markup, TikiWiki markup, Creole 1.0, Vimwiki markup, OPML, Emacs Org-Mode, Emacs Muse, txt2tags, Microsoft Word docx, LibreOffice ODT, EPUB, or Haddock markup to.

## About This Image

Two images are created for each release: A base image with only Pandoc installed and a "full" image with the following packages installed:

- [tex-live](https://pkgs.alpinelinux.org/package/edge/community/x86_64/texlive-full)
- [texmf-dist](https://pkgs.alpinelinux.org/package/edge/community/x86_64/texmf-dist)

## Using Docker Compose 

You can use `docker-compose up` to run Pandoc and convert your files. The following example is taken frome this [project's Github repo](https://github.com/jonbrouse/docker-pandoc).

```
version: "3"
services:

  pandoc:
    image: jonbrouse/docker-pandoc:2.3-full
    build: .
    volumes:
      - ./:/pandoc
    command: |
      --pdf-engine xelatex
      --listings
      --template common/pdf-template.tex
      example.md -o example.pdf
```
