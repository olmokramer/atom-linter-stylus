{resolve, dirname, basename} = require 'path'
{Range} = require 'atom'
linterPath = atom.packages.getLoadedPackage('linter').path
Linter = require "#{linterPath}/lib/linter"
stylus = null

class LinterStylus extends Linter
  @syntax: 'source.stylus'
  linterName: 'stylus'

  constructor: (editor) ->
    super editor
    @sub = atom.config.observe 'linter-stylus.stylusPath', (stylusPath) ->
      stylus = require resolve stylusPath

  destroy: ->
    @sub.dispose()

  parseStylusFile: (data, filePath, callback) ->
    activeFilePath = atom.workspace.getActiveTextEditor().getPath()
    return unless basename(filePath) is basename(activeFilePath)
    stylus data
      .set 'filename', filePath
      .set 'paths', [dirname(activeFilePath)]
      .render (err, css) =>
        unless err?
          return callback []
        lines = err.message.split(/\n/).map (line) -> line.replace /^\s*/, ''
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
