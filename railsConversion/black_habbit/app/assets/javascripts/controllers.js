


var black_HabitControllers = angular.module('black_HabitControllers', []);

black_HabitControllers.controller('resultsCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('http://localhost:3000/searches/search.json').success(function(data) {
      $scope.phones = data;
    });
    $scope.orderProp = 'name';
  }]);

