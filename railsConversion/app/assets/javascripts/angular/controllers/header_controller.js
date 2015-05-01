black_Habit.controller('headerctl', ['$scope', 'Authentication',function($scope,Authentication) {
	
	console.log("----Submit the Form !!!!----")
	$scope.submitLogin=function(){

		var credentials={
			password:$scope.password,
			email:$scope.email
		}
		Authentication.login(credentials)

	}




}]);

