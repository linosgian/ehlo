## Description

This is my blog's source code. Hugo is used to generate the content.

## Development

- Clone this repo (`--recurse-submodules` to grab the theme too)
- Install Hugo's [latest release](https://github.com/gohugoio/hugo/releases)
- Run `hugo serve -D`
- View your changes under `localhost:1313`
- Once you're happy with the changes, push them to remote
- Pull the changes from production and just run `hugo` under `~/hugo-sites/ehlo/`. This will generate the files
and put them in right location for nginx to serve them.
