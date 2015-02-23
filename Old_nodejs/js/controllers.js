
var black_HabitControllers = angular.module('black_HabitControllers', []);

black_HabitControllers.controller('resultsCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('testSearch.json').success(function(data) {
      $scope.phones = data;
    });
    $scope.orderProp = 'age';
  }]);





blackHabbit.controller('ResultDatailCtrl', ['$scope', '$routeParams', 'result',
  function($scope, $routeParams, result) {
    $scope.result = result.get({resultId: $routeParams.resultId}, function(result) {
      $scope.mainImageUrl = result.images[0];
    });

    $scope.setImage = function(imageUrl) {
      $scope.mainImageUrl = imageUrl;
    }
  }]);