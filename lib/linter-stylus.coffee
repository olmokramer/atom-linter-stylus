fs = require 'fs'
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
      stylus = require stylusPath

  destroy: ->
    @sub.dispose()

  parseStylusFile: (data, filePath, cb) ->
    activeFilePath = atom.workspace.getActiveTextEditor().getPath()
    return unless basename(filePath) is basename(activeFilePath)
    @getIncludePaths (err, includePaths) =>
      # if err?
      #   return cb []
      # console.log [dirname(activeFilePath)].concat includePaths
      stylus data
        .set 'filename', filePath
        .set 'paths', [dirname(activeFilePath)].concat includePaths
        .render (err, css) =>
          unless err?
            return cb []
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

          cb messages

  lintFile: (filePath, cb) ->
    fs.readFile filePath, 'utf8', (err, data) =>
      return cb [] if err
      @parseStylusFile data, filePath, cb

  getActiveProjectRoot: ->
    filePath = atom.workspace.getActiveTextEditor().getPath()
    for root in atom.project.getPaths() when filePath.match root
      return root
    null

  getIncludePaths: (cb) ->
    configFile = resolve @getActiveProjectRoot(), 'package.json'
    fs.exists configFile, (exists) ->
      return cb null, [] unless exists
      fs.lstat configFile, (err, stat) ->
        return cb err, null if err?
        return cb 'package.json is directory', null if stat.isDirectory()
        fs.readFile configFile, (err, data) ->
          return cb err, null if err?
          data = JSON.parse data.toString()
          if data['linter-stylus']
            data = data['linter-stylus']
          cb null, data.includePaths ? []

module.exports = LinterStylus
