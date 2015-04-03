{View} = require 'atom'
{BufferedProcess} = require 'atom'
Convert = require 'ansi-to-html'
converter = new Convert()
module.exports =
class GulpHelperView extends View
  processes = {}
  command = if process.platform == 'win32' then 'gulp' else '/usr/local/bin/gulp'
  args = ['watch', '--color']
  @content: ->
    @div class: "gulp-helper tool-panel panel-bottom", =>
      @div class: "panel-heading affix", 'Gulp Output'
      @div class: "panel-body padded"

  initialize: (serializeState) ->
    atom.workspaceView.command "gulp-helper:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
      # Kill all gulp processes
      for projectPath, process of processes
        if process
          process.kill()
    else
      atom.workspaceView.prependToBottom(this)
      @runGulp()

  runGulp: ->
    #Clear our console
    atom.workspaceView.find('.gulp-helper .panel-body').html('')
    # Run gulp for each root folder open
    for projectPath in atom.project.getPaths()
      do (projectPath) =>
        options = {
            cwd: projectPath
        }
        # Get root folder name as displayed by Atom (i.e. last segment of path)
        projectPathName = projectPath.split(path.sep).filter((path) -> path isnt '').pop()
        # Make sure output knows which root folder the output/error was caused in
        stdout = (output) => @gulpOut(output, projectPathName)
        stderr = (code) => @gulpErr(code, projectPathName)
        exit = (code) => @gulpErr(code, projectPathName)
        # Run process and store in cache so we can exit later
        processes[projectPath] = new BufferedProcess({command, args, options, stdout, stderr, exit})

  setScroll: ->
    gulpHelper = atom.workspaceView.find('.gulp-helper')
    gulpHelper.scrollTop(gulpHelper[0].scrollHeight)

  gulpOut: (output, projectPath) =>
    for line in output.split("\n").filter((lineRaw) -> lineRaw isnt '')
      stream = converter.toHtml(line);
      atom.workspaceView.find('.gulp-helper .panel-body').append "<div class='text-highighted'><span class='folder-name'>#{projectPath}</span> #{stream}</div>"
    @setScroll()

  gulpErr: (code, projectPath) =>
    atom.workspaceView.find('.gulp-helper .panel-body').append "<div class='text-error'><span class='folder-name'>#{projectPath}</span> Error Code: #{code}</div>"
    @setScroll()

  gulpExit: (code, projectPath) =>
    atom.workspaceView.find('.gulp-helper .panel-body').append "<div class='text-error'><span class='folder-name'>#{projectPath}</span> Exited with error code: #{code}</div>"
    @setScroll()
