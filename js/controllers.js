/* Controllers */

var blackHabbit = angular.module('blackHabbit', []);

blackHabbit.controller('homeCtrl', ['$scope', 'result',
  function($scope, result) {
    $scope.results = result.query();
    $scope.orderProp = 'relevance';
  }]);

blackHabbit.controller('ResultDetailCtrl', ['$scope', '$routeParams', 'result',
  function($scope, $routeParams, result) {
    $scope.result = result.get({resultId: $routeParams.resultId}, function(result) {
      $scope.mainImageUrl = result.images[0];
    });

    $scope.setImage = function(imageUrl) {
      $scope.mainImageUrl = imageUrl;
    }
  }]);
