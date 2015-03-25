# This package is no longer supported, use [linter-stylint](https://atom.io/packages/linter-stylint) instead
<br><br>

# linter-stylus

This plugin for [Linter](https://github.com/AtomLinter/Linter) provides an interface to [stylus](https://learnboost.github.io/stylus). It will be used with files that have the `Stylus` syntax.

## Installation

Linter package must be installed in order to use this plugin. If Linter is not installed, please follow the instructions [here](https://github.com/AtomLinter/Linter).

## Plugin installation

```shell
$ apm install linter-stylus
```

## Stylus include paths

Stylus has a `paths` option, which is an array to look in for relative `@import`s. This option cannot be detected by `linter-stylus`, and it will throw errors that it can't find the `@import`s. To solve this, you can add a `linter-stylus` section to the project root's `package.json` to defines these include paths:
```cson
# package.json
{
  "name": "project-name",
  "version": "v1.0.0",
  "etc...": "",
  "linter-stylus": {
    "includePaths": [
      "/home/user/some/dir/with/stylus/includes",
      "/some/other/path"
    ]
  }
}
```
Now stylus will also look in those directories for an `@import` file when linting.

## Settings

You can configure linter-stylus from the settings view in Atom, or by editint `~/.atom/config.cson`:

```cson
'linter-stylus':
  # if you don't want to use the bundled version of stylus
  'stylusPath': '/usr/local/lib/node_modules/stylus'
```
