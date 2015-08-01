black_Habit.controller('main', ['$scope', '$http',function($scope, $http) {
  $scope.alerts=[];
  $scope.addAlert = function(txt) {
    $scope.alerts.push({msg: txt});
  };

  $scope.closeAlert = function(index) {
    $scope.alerts.splice(index, 1);
  };
  



}]);

