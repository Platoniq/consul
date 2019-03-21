App.Answers =

  initializeAnswers: (answers)->
    $(answers).on 'cocoon:after-insert', (e, new_answer) ->
      order = $(answers).find("[name$='[given_order]']").size()
      $(new_answer).find("[name$='[given_order]']").val(order)

  nestedAnswers: ->
    $('.js-answers').each (index, answers) ->
      App.Answers.initializeAnswers(answers)

  initialize: ->
    App.Answers.nestedAnswers()
