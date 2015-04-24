var black_Habit= angular.module('black_Habit', ['ngCookies','ui.bootstrap']);



black_Habit.filter('startFrom', function() {
    return function(input, start) {
        start = +start; //parse to int
        return input.slice(start);
    }
});


black_Habit.controller('resultCtrl', ['$scope', '$http','Auth',function($scope, $http, Auth) {
  $scope.currentPage = 1;
  $scope.results=[];
  $scope.pageSize = 5;




  $scope.numberOfPages=function(){
      return Math.ceil($scope.results.length/$scope.pageSize);                
  }


	$scope.starList = function(num) {
	     return new Array(num);   
	}
 	$scope.genSearch = function(query) {
		$http.get('http://localhost:3000/searches/search.json', {params: { blackHabbitPrimarySearch:query,limit:100,histNum:10 }}).success(function(a) {  //THIS IS SUPER DANGEROUS!
	   		console.log(a);
	   		$scope.results = a;
	   		return $scope.results;
    	});
    };

    $scope.setActiveItem = function(val) { //Pretty sure there might be more elegant way of doing this - BUT its simple!
        console.log($cookieStore.get('email'))
        $scope.activeItem = val;
        // console.log($scope.results)
        $scope.resultInFocus = $scope.results.filter(function (result) { return result.id == val })[0];
        $scope.historiesInFocus = $scope.resultInFocus.histories;
        $scope.possible_addresses = $scope.resultInFocus.possible_addresses;
        $scope.resultInFocus.desc = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)"
        // console.log($scope.results.filter(function (result) { return result.id == val }))

    };
    $scope.orderProp = 'name';  // Need to make the ordering/sorting tools ALSO need to work on gettin some security for sql stuff worked out
    $scope.currentBlockRate =4; // Debating whether or not to just have this make an api call to that exchange site or just use erb orrrr include it in every search?
    $scope.resultStarStatus =4; // Need to tie this to something in the db soon
    
    
    $scope.expiresIn = function(num){  // This could be in a better spot I think.
      // console.log(num)
    	timeRemaining = num/$scope.currentBlockRate/24; //Bad math?
    	// console.log(timeRemaining.toFixed(2))
  		if (timeRemaining < 1) {
  			return "Expired";

  		}else{
  			return "Roughly " + timeRemaining.toFixed(2) + " days";
  		}
    }

}]);

