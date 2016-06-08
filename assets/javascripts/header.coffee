ready = ->
  $("#js--btn-upload").click ->
    $('.js--ct-body').fadeOut 200
    $('.js--ct-upload-form').fadeIn 250

  $("#js--close-upload-form").click ->
    $('.js--ct-upload-form').fadeOut 200
    $('.js--ct-body').fadeIn 250

$(document).ready(ready)
$(document).on('page:load', ready)