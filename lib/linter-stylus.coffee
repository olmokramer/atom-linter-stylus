linterPath = atom.packages.getLoadedPackage('linter').path
Linter = require "#{linterPath}/lib/linter"
fs = require 'fs'
path = require 'path'
stylus = require 'stylus'
{Range} = require 'atom'

class LinterStylus extends Linter
  @syntax: 'source.stylus'
  linterName: 'stylus'

  parseStylusFile: (data, filePath, callback) ->
    stylus data
      .set 'filename', filePath
      .render (err, css) =>
        unless err?
          return callback []

        lines = err.message.split /\n/
        lines = lines.map (line) -> line.replace /^\s*/, ''
        [..., lineNr, column] = lines.shift().match /.*:(\d+):(\d+)/
        lineIdx = Math.max 0, lineNr - 1

        messages = []
        for line in lines when !!line
          messages.push
            line: lineNr
            col: column
            message: line
            level: 'error'
            linter: @linterName
            range: new Range [lineIdx, column], [lineIdx, @lineLengthForRow lineIdx]

        callback messages

  lintFile: (filePath, callback) ->
    fs.readFile filePath, 'utf8', (err, data) =>
      return callback [] if err
      @parseStylusFile data, filePath, callback

module.exports = LinterStylus
