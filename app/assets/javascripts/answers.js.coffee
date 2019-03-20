App.Answers =

  initializeAnswers: (answers)->
    console.log 'initializeAnswers'
    $(answers).on 'cocoon:after-insert', (e, new_answer) ->
      index = $(answers).find("[name$='[given_order]']").size()
      $(new_answer).find("[name$='[given_order]']").val(index)

  nestedAnswers: ->
    $('.js-answers').each (index, answers) ->
      App.Answers.initializeAnswers(answers)

  initialize: ->
    App.Answers.nestedAnswers()
