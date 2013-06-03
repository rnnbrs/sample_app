(($) ->
  'use strict'
    
  $.fn.counter = ->
    count = (elem) ->
      size = elem.val().length
      target = $('#micropost_counter')
      target.text (140 - size)
    
    @each ->
      elem = $(this)
      count elem
      elem.keyup ->
        count elem
      elem
    
    $.fn.counter.defaults =
      maxSize = 140
      warningSize = 130
      
) (jQuery)

jQuery ->
  $('#micropost_content').counter()
