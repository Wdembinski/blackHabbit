var black_Habit= angular.module('black_Habit', []);

black_Habit.controller('resultCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('http://localhost:3000/searches/search.json').success(function(a) {
      $scope.results = a;
    });
    $scope.orderProp = 'name';
  }
]);