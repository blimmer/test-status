{View} = require 'atom-space-pen-views'

TestStatusView = require './test-status-view'
CommandRunner  = require './command-runner'

module.exports =
# Internal: A status bar view for the test status icon.
class TestStatusStatusBarView extends View

  # Internal: Initialize test-status status bar view DOM contents.
  @content: ->
    @div click: 'toggleTestStatusView', class: 'inline-block', =>
      @span outlet:  'testStatus', class: 'test-status icon icon-hubot', tabindex: -1, ''

  # Internal: Initialize the status bar view and event handlers.
  initialize: ->
    @testStatusView = new TestStatusView
    @commandRunner = new CommandRunner(@testStatus, @testStatusView)
    @attach()

    @initialSub   = true
    @editorSub    = null
    @statusBarSub = atom.workspace.observeTextEditors (editor) =>
      # On the initial run, only subscribe to the active text editor.
      # There is technically no active on subsequent firings of this observer.
      # If atom introduces an observeActiveTextEditor, that'd be ideal to use here.
      if @initialSub
        return unless editor == atom.workspace.getActiveTextEditor()
        @initialSub = false

      @editorSub?.dispose()
      @editorSub = editor.onDidSave =>
        return unless atom.config.get('test-status.autorun')
        @commandRunner.run()

    atom.commands.add 'atom-workspace',
      'test-status:run-tests': => @commandRunner.run()

  # Internal: Attach the status bar view to the status bar.
  #
  # Returns nothing.
  attach: ->
    statusBar = document.querySelector('status-bar')

    if statusBar?
      @statusBarTile = statusBar.addLeftTile(item: this, priority: 100)

  # Internal: Detach and destroy the test-status status barview.
  #
  # Returns nothing.
  destroy: ->
    @testStatusView.destroy()
    @testStatusView = null

    @statusBarSub.dispose()
    @statusBarSub = null
    @editorSub.dispose()
    @editorSub = null

    @detach()

  # Internal: Called on click of status bar view
  #
  # Returns nothing
  toggleTestStatusView: ->
    @testStatusView.toggle()
