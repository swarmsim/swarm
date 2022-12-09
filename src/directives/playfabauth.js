/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';
import * as views from '../views';

/**
 * @ngdoc directive
 * @name swarmApp.directive:playfab
 * @description
 * # playfab
*/
angular.module('swarmApp').directive('playfabauth', playfab => ({
  template: views.playfab.auth,
  restrict: 'EA',
  scope: {},

  link(scope, element, attrs) {
    scope.setActive = function(active) {
      scope.forgotSuccess = null;
      scope.error = null;
      scope.active = active;
      return false;
    };
    scope.setActive('login');
    scope.form = {};
    //scope.form = {email: 'test@erosson.org', password: 'testtest', password2: 'testtest'}
    const handleError = function(error) {
      scope.error = {
        main: (error != null ? error.errorMessage : undefined),
        email: __guard__(__guard__(error != null ? error.errorDetails : undefined, x1 => x1.Email), x => x[0]),
        password: __guard__(__guard__(error != null ? error.errorDetails : undefined, x3 => x3.Password), x2 => x2[0])
      };
      return console.log('fail', error, scope.error);
    };

    scope.runSignup = function() {
      scope.error = null;
      return playfab.signup(scope.form.email, scope.form.password, scope.form.remember).then(
        data => console.log('success', data),
        handleError);
    };
    scope.runLogin = function() {
      scope.error = null;
      return playfab.login(scope.form.email, scope.form.password, scope.form.remember).then(
        data => console.log('success', data),
        handleError);
    };
    return scope.runForgot = function() {
      scope.forgotSuccess = null;
      scope.error = null;
      return playfab.forgot(scope.form.email).then(
        function(data) {
          console.log('success', data);
          return scope.forgotSuccess = true;
        },
        handleError);
    };
  }
}));

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}