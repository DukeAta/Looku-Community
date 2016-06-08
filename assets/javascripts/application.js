// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require autocomplete-rails
//= require twitter/bootstrap
//= require landerapp.min.js
//= require landerapp.js
//= require sweet-alert
//= require social-share-button
//= require_tree .


$(document).ready(function($) {
    $("#voted").click(function(){
        this.style.color = "red";
    });

    var previousScroll = 0,
    headerOrgOffset = $('.main-navbar-fixed #main-navbar').height() - 20;

    //$('#header-wrap').height($('#header').height());

    $(window).scroll(function () {
        var currentScroll = $(this).scrollTop();
        if (currentScroll > headerOrgOffset) {
            if (currentScroll > previousScroll) {
                $('.main-navbar-fixed').slideUp();
            } else {
                //$('.main-navbar-fixed').slideDown();
            }
        } else if( currentScroll <= headerOrgOffset ) {
            $('.main-navbar-fixed').slideDown();
        }
        previousScroll = currentScroll;
    });

});
