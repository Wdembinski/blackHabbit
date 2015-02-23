var black_Habit= angular.module('black_Habit', []);

black_Habit.controller('resultCtrl', ['$scope', '$http',function($scope, $http) {
	// $scope.genSearch = function(query) {
	// 	$http.get('http://localhost:3000/searches/search.json').success(function(a) {
	//    		$scope.results = a;
	//    		return $scope.results;
 //    	});
 //    };
 	$scope.genSearch = function(query) {
		$http.get('http://localhost:3000/searches/search.json', {params: { blackHabbitPrimarySearch:query }}).success(function(a) {
	   		$scope.results = a;
	   		return $scope.results;
    	});
    };
    $scope.orderProp = 'name';
  }
]);