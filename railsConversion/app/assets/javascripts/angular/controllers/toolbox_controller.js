black_Habit.controller('toolBoxCtl', ['$scope', '$http',function($scope) {

	$scope.tabs = [{title: 'Home'},
								 {title: 'Tags'},
								 {title: 'Something'}
								];

	$scope.currentTab = '';

	$scope.onClickTab = function (tab) {
	    $scope.currentTab = tab.title;
	}
	
	$scope.isActiveTab = function(tabUrl) {
	    return tabUrl == $scope.currentTab;
	}
  



}]);

