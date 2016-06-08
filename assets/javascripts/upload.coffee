ready = ->
  document.getElementById("ct-document-file").onchange = ->
    fileName = $('input[type=file]').val().split('\\').pop();
    if fileName? && fileName != ''
      $('label[for=ct-document-file]').html(fileName)
    if fileName? && $("#document_title").val() && $("#document_title").val() != ''
      $('.ct-small-submit-btn').prop('disabled', false);
  document.getElementById("document_title").onchange = ->
    fileName = $('input[type=file]').val().split('\\').pop();    
    if fileName && fileName != '' && $("#document_title").val() && $("#document_title").val() != ''
      $('.ct-small-submit-btn').prop('disabled', false);
$(document).ready(ready)
$(document).on('page:load', ready)