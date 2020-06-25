global.$ = global.jQuery = $ = require "jquery"

requestAnimFrame = require "animationframe"
require "./preloadjs-0.6.2.min"
require "./soundjs-0.6.2.min"
require "bootstrap/assets/javascripts/bootstrap/transition"
require "bootstrap/assets/javascripts/bootstrap/tooltip"
require "bootstrap/assets/javascripts/bootstrap/popover"
require "bootstrap/assets/javascripts/bootstrap/modal"
#require "bootstrap/assets/javascripts/bootstrap/affix"
#require "bootstrap/assets/javascripts/bootstrap/tab"
#require "bootstrap/assets/javascripts/bootstrap/dropdown"
#require "bootstrap/assets/javascripts/bootstrap/collapse"
#require "bootstrap/assets/javascripts/bootstrap/carousel"
#require "bootstrap/assets/javascripts/bootstrap/tooltip"

init = ()->
  $(window).bind('resize', ()->
    setImagePopovers()
  )
  $('.home .btn').bind('click', ()->
    gotoPage($('.home.page'), $('.quiz.page'))
  )
  $('#successModal .btn.save-button').bind('click', ()->
    $('#successModal').modal('hide')
    gotoNextQuestion($('.question-container.active'))
  )
  $('#errorModal .btn.save-button').bind('click', ()->
    $('#errorModal').modal('hide')
  )
  $('#finishModal .btn.save-button').bind('click', ()->
    reset()
    gotoPage($('.quiz.page'), $('.home.page'))
  )
  $('.quiz .answers a').bind('click', ()->
    $('.answers a').popover('hide')

    if $(this).data('isCorrect')
      $('.question-container.active .answers a').addClass('disabled')
      $(this).addClass('success')
      setScore()
    else
      $(this).addClass('error').addClass('disabled')

    modal = if $(this).data('isCorrect') then $('#successModal') else $('#errorModal')
    if $(this).data('isCorrect') && $('.question-container.active').next().length==0
      modal = $('#finishModal')
      modal.find('.modal-body').html($(this).data('description') + '<br><hr><br>' + $('.quiz.page').data('endGameMessage'))
      setScore()
    else
      modal.find('.modal-body').html($(this).data('description'))

    if $(this).data('isCorrect')
      $('.current-score').html "+#{getCurrentScore()}"
      $('.current-score').addClass('visible').removeClass('hidden')
      createjs.Sound.play("success")
      setTimeout(()->
        modal.modal('show')
        centerModal(modal, $('.page.active'))
        $('.current-score').removeClass('visible').addClass('hidden')
      , 1000)
    else
      modal.modal('show')
      centerModal(modal, $('.page.active'))
  )
  preloadSound()
  setImagePopovers()
  hideHiddenElements()
  setScore()

setImagePopovers = ()->
  if $(window).width()>991
    $('.answers a').popover({
      delay: { "show": 500, "hide": 100 }
      animation: true
      html: true
      trigger: "hover"
      container:"body"
      placement:"right"
    })
  else
    $('.answers a').popover('destroy')

hideHiddenElements = ()->
  $('.page').each(()->
    $(this).css('display', 'none') if !$(this).hasClass('active')
  )
  $('.question-container').each(()->
    $(this).css('display', 'none') if !$(this).hasClass('active')
  )

reset = ()->
  $('.answers a').popover('hide')
  $('.modal').modal('hide')
  $('.page').each(()->
    $(this).attr('style', '')
  )
  $('.question-container.active').removeClass('active')
  $('.question-container').first().addClass('active')
  $('.question-container').each(()->
    $(this).attr('style', '')
  )
  $('.quiz .answers a').each(()->
    $(this).removeClass('disabled').removeClass('success').removeClass('error')
    $(this).attr('style', '')
  )
  setScore()
  hideHiddenElements()

gotoPage = (activePage, nextPage)->
  return if nextPage.length==0 || activePage.length==0

  nextPage.attr('style', '')
  nextPage.css('display', 'block')

  setTimeout(()->
    activePage.attr('style', '')
    activePage.removeClass('active')
    activePage.css('top', '-100%')
    nextPage.addClass('active')

    setTimeout(()->
      activePage.css('display', 'none')
    , 1000)
  , 50)

gotoNextQuestion = (activeQuestion)->
  return if activeQuestion.next().length==0

  activeQuestion.next().css('display', 'block')
  $('.answers a').popover('hide')
  setTimeout(()->
    activeQuestion.removeClass('active')
    activeQuestion.css('left', '-100%')
    activeQuestion.next().addClass('active')
    setTimeout(()->
      activeQuestion.css('display', 'none')
    , 1000)
  , 50)

centerModal = (modal, element)->
  setTimeout(()->
    dialog = modal.find('.modal-dialog')
    dialog.css('transform', "translate(0, #{(element.height()-dialog.height())/2}px)");
  , 150)

getCurrentScore = ()->
  $('.question-container.active .answers a').length - $('.question-container.active .answers a.error').length

calculateScore = ()->
  score = 0
  $('.question-container').each(()->
    if $(this).find('.answers a.success').length>0
      totalAnswers = $(this).find('.answers a').length
      errorAnswers = $(this).find('.answers a.error').length
      score += totalAnswers-errorAnswers
  )
  return score

preloadSound = ()->
  queue = new createjs.LoadQueue()
  queue.installPlugin(createjs.Sound)
  queue.loadManifest([
    {id:"success", src:SUCCESS_SOUND}
  ])
totalAswers = ()->  return $('.question-container .answers a').length
setScore = ()-> $('.score-value').html "#{calculateScore()} / #{totalAswers()}"

init()
