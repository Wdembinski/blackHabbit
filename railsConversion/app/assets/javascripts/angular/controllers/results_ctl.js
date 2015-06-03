black_Habit.controller('resultCtrl', ['$state','$scope', '$http','Authentication',function($state,$scope, $http, Authentication) {
  $scope.currentPage = 1;
  $scope.results=[];
  $scope.pageSize = 10;

////////////////////////////////////////////////////////////////////////

                    ///collapse stuff

  $scope.isCollapsed = true;

  $scope.numberOfPages=function(){
      return Math.ceil($scope.results.length/$scope.pageSize);                
  }


	$scope.starList = function(num) {
	     return new Array(num);   
	}

 	$scope.genSearch = function(query) {
		$http.get('http://localhost:3000/searches/search.json', {params: { blackHabbitPrimarySearch:query,limit:100,histNum:10 }}).success(function(a) {  //THIS IS SUPER DANGEROUS!
	   		$scope.results = a;
	   		return $scope.results;
    	});
    };

    $scope.setActiveItem = function(val) { //Pretty sure there might be more elegant way of doing this - BUT its simple!

        if(Authentication.authorize()){
          
          console.log("$$$$$$$$$$$$$--Current State--$$$$$$$$$$$")
          console.log("$$                                     $$")
          console.log("$$           User is logged in         $$")
          console.log($state.current)
          console.log("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
        }else{
          console.log("$$$$$$$$$$$$$--Current State--$$$$$$$$$$$")
          console.log("$$                                     $$")
          console.log("$$           User is logged out        $$")
          console.log($state.current)
          console.log("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
        }
      

        $scope.activeItem = val;
        // console.log($scope.results)
        $scope.resultInFocus = $scope.results.filter(function (result) { return result.id == val })[0];
        $scope.historiesInFocus = $scope.resultInFocus.histories;
        $scope.possible_addresses = $scope.resultInFocus.possible_addresses;
        $scope.resultInFocus.desc = "This is filler description text!text!text!text!text!text!text!text!text!text!text!text!text!"
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

