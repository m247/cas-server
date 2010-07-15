jQuery(document).ready(function($) {
  $('#login-form').submit(function(ev) {
    var btn = $(ev.target).children('input[type=submit]');
    if ( btn.attr('data-disable_with') )
      btn.val(btn.attr('data-disable_with'));
    btn.attr('disabled', 'disabled');
  });

  if ( $('#username') ) {
    $('#username').focusin(function(ev) {
      var name = $(ev.target).attr('name');
      $("label[for="+ name +"]").addClass('focused');
    });
    $('#username').focusout(function(ev) {
      var name = $(ev.target).attr('name');
      $("label[for="+ name +"]").removeClass('focused');
    });
    $('#username').focus();
  }
});
