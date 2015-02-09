'use strict';

/* Lets get started with some routes -  */

var blackHabbit = angular.module('blackHabbit', [
  'ngRoute',
]);

blackHabbit.config(['$routeProvider',function($routeProvider) {
      $routeProvider.
        when('/search', {
          templateUrl: 'partials/result.html',
          controller: 'resultsCtrl'
        }).
        // when('/search/:phoneId', {
        //   templateUrl: 'partials/phone-detail.html',
        //   controller: 'PhoneDetailCtrl'
        // }).
        otherwise({
          redirectTo: '/search'
        });
   }]);