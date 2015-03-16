# linter-stylus

This plugin for [Linter](https://github.com/AtomLinter/Linter) provides an interface to [stylus](https://learnboost.github.io/stylus). It will be used with files that have the `Stylus` syntax.

## Installation

Linter package must be installed in order to use this plugin. If Linter is not installed, please follow the instructions [here](https://github.com/AtomLinter/Linter).

## Plugin installation

```shell
$ apm install linter-stylus
```

## Settings

You can configure linter-stylus from the settings view in Atom, or by editint `~/.atom/config.cson`:

```cson
'linter-stylus':
  # if you don't want to use the bundled version of stylus
  'stylusExecutablePath': '/usr/local/lib/node_modules/stylus/bin/stylus'
```