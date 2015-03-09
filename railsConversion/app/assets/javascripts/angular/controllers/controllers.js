var black_Habit= angular.module('black_Habit', []);

black_Habit.controller('resultCtrl', ['$scope', '$http',function($scope, $http) {


	$scope.starList = function(num) {
	     return new Array(num);   
	}
 	$scope.genSearch = function(query) {
		$http.get('http://localhost:3000/searches/search.json', {params: { blackHabbitPrimarySearch:query,limit:100,histNum:10 }}).success(function(a) {
	   		console.log(HistoriesFromResults(a));
	   		$scope.results = a;
	   		return $scope.results;
    	});
    };
    httpSuccess = function(response) {
        $scope.persons = response;
    }
    $scope.orderProp = 'name';
    $scope.currentBlockRate =4;
    $scope.resultStarStatus =4;


}]);


function HistoriesFromResults(array){
	histories=[];
	var length = array.length - 1;
	console.log(array[50][1])
	console.log("HE:::::PPp")
	for (var i = length;i != 0; i--) {
		if(array[i].address){
			// console.log("WIN")
			histories.push(array[i]);
		}
	}
	return histories
	// console.log(histories);
}