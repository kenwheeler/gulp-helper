GulpHelperView = require './gulp-helper-view'

module.exports =
  configDefaults:
    useCoffeeGulp: false
    args: 'watch'

  gulpHelperView: null

  activate: (state) ->
    @gulpHelperView = new GulpHelperView(state.gulpHelperViewState)

  deactivate: ->
    @gulpHelperView.destroy()

  serialize: ->
    gulpHelperViewState: @gulpHelperView.serialize()
