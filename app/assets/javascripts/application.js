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
//= require foundation
//= require jquery
//= require handlebars
//= require ember
//= require ember-data
//= require ember-google-analytics-jb/ember-google-analytics
//= require_self
//= require assets
//= require rwatcher

// for more details see: http://emberjs.com/guides/application/
Rwatcher = Ember.Application.create({
    // Basic logging, e.g. "Transitioned into 'post'"
    LOG_TRANSITIONS: true,

    // Extremely detailed logging, highlighting every internal
    // step made while transitioning into a route, including
    // `beforeModel`, `model`, and `afterModel` hooks, and
    // information about redirects and aborted transitions
    LOG_TRANSITIONS_INTERNAL: true
});

// set global constants
Ember.ControllerMixin.reopen({
    GLOBAL_DOMAIN:'sledovani-realit.cz',
    GLOBAL_FREE_LIMIT:2000
});
//= require_tree .

$(function(){ $(document).foundation(); });
