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
    files = [
      resolve @getActiveProjectRoot(), 'package.json'
      resolve @getActiveProjectRoot(), 'linter-stylus.json'
    ]
    done = 0
    for file in files
      if fs.existsSync(file) and fs.lstatSync(file).isFile()
        fs.readFile file, (err, data) ->
          done++
          if err?
            return cb err, null
          data = JSON.parse data.toString()
          if data['linter-stylus']
            data = data['linter-stylus']
          if data.includePaths?
            cb null, data.includePaths
          else if done is files.length
            cb null, []

module.exports = LinterStylus
