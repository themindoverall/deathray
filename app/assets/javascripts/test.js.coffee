#= require jquery



class Step
  @load: (data) ->
    switch data.type
      when 'wait'
        new WaitStep(data)
      when 'text'
        new TextStep(data)
      when 'll'
        new ParallelStep(data)
      when 'seq'
        new SequenceStep(data)
  constructor: (@data) ->
    @finished = false
  start: () ->
  update: (delta) ->
  end: () ->

class SequenceStep
  constructor: (@data) ->
    @steps = (Step.load(d) for d in @data.sequence)
    console.log @steps
    @currentStep = @steps.shift()
  start: () ->
    @currentStep.start()
  update: () ->
    @currentStep.update()
    if @currentStep.finished
      @currentStep.end()
      if @steps.length > 0
        @currentStep = @steps.shift()
        @currentStep.start()
      else
        @finished = true

class ParallelStep extends Step
  constructor: (@data) ->
    @steps = (Step.load(d) for d in @data.steps)
  start: () ->
    for s in @steps
      s.start()
  update: (delta) ->
    @finished = true
    for s in @steps
      s.update(delta)
      @finished and= s.finished

class WaitStep extends Step
  start: () ->
    @startTime = new Date()
  update: (delta) ->
    @finished = (new Date()) - @startTime > @data.time

class TextStep extends Step
  start: () ->
    console.log(@data.body)
    @finished = true
$ ->
  seq = null
  $.get('/test.json', (data) ->
    seq = new SequenceStep(data)
    seq.start()
    runTimer()
  , 'json').error((a)->
    console.log('wat', a, this)
  )
  now = new Date()
  last = now
  runTimer = () ->
    now = new Date()
    delta = (now - last) * 0.001
    seq.update(delta)

    last = now
    window.webkitRequestAnimationFrame(runTimer)
