'use strict';

/* Lets get started with some routes -  */

var blackHabbit = angular.module('blackHabbit', [
  'ngRoute',
]);

blackHabbit.config(['$routeProvider',function($routeProvider) {
      $routeProvider.
        when('/search', {
          templateUrl: 'partials/resultList.html',
          controller: 'PhoneListCtrl'
        }).
        // when('/search/:phoneId', {
        //   templateUrl: 'partials/phone-detail.html',
        //   controller: 'PhoneDetailCtrl'
        // }).
        otherwise({
          redirectTo: '/search'
        });
   }]);


// // ====================== STUFF
// var phonecatApp = angular.module('phonecatApp', [
//   'ngRoute',
//   'phonecatControllers',
//   'phonecatFilters',
//   'phonecatServices',
//   'phonecatAnimations'
// ]);



// phonecatApp.config(['$routeProvider',
//     function($routeProvider) {
//       $routeProvider.
//         when('/search', {
//           templateUrl: 'partials/phone-list.html',
//           controller: 'PhoneListCtrl'
//         }).
//         when('/search/:phoneId', {
//           templateUrl: 'partials/phone-detail.html',
//           controller: 'PhoneDetailCtrl'
//         }).
//         otherwise({
//           redirectTo: '/search'
//         });
//    }]);