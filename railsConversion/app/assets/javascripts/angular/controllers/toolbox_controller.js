black_Habit.controller('toolBoxCtl', ['$scope', '$http','$state',function($scope,$http,$state) {

	$scope.tabs = [{title: 'Home'},
								 {title: 'Tags'},
								 {title: 'Something'}
								];

	$scope.currentTab = 'Home';

	$scope.onClickTab = function (tab) {
	    $scope.currentTab = tab.title;
	}
	
	$scope.isActiveTab = function(tabUrl) {
	    return tabUrl == $scope.currentTab;
	}

  $scope.tab_state= function(){
  	// console.log($state.current.name)
  	return $state.current.name;
  }

  // $scope.state = $state.current.name;

}]);

