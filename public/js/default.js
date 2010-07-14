jQuery(document).ready(function($) {
  $('#login-form').submit(function(ev) {
    var btn = $(ev.target).children('input[type=submit]');
    if ( btn.attr('data-disable_with') )
      btn.val(btn.attr('data-disable_with'));
    btn.attr('disabled', 'disabled');
  });
});
