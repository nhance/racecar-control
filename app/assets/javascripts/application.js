// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/autocomplete
//= require semantic-ui
//= require_tree .
//= require_self

$(document).on('ready page:load', function() {
  $('.ui.dropdown:not(.manual)').dropdown();

  $('.close.icon').on('click', function() {
    $(this).closest('.message').transition('slide down');
  });

  $('[data-modal]').on('click', function(e) {
    var modal_id = $(this).data('modal');

    $('#' + modal_id).modal('show');
  });

  $('.menu .item').tab();

  $('.ui.form').form({
    required: {
      identifier: 'required',
      rules: [
        {
          type: 'empty',
          prompt: 'Please fill this in'
        }
      ]
    }
  });
});
