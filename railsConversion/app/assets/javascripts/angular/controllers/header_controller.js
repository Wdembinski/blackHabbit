black_Habit.controller('headerCtrl', ['$scope', 'Authentication',function($scope,Authentication) {
	$scope.login_form={};

	$scope.submitLogin=function(){
		// console.log("----Submit the Form !!!!----")
		// console.log($scope)
		// console.log($scope.login_form.email)
		// console.log($scope.login_form.password)
		var credentials={
			 password:$scope.login_form.password
		  ,email:$scope.login_form.email
		}

		Authentication.login(credentials)
	}
	$scope.logout=function(){
		Authentication.logout()

	}










	   // .controller("MyController", function($scope, $http) {
	   //   $scope.myForm = {};
	   //   $scope.myForm.name = "Jakob Jenkov";
	   //   $scope.myForm.car  = "nissan";

	   // $scope.myForm.submitTheForm = function(item, event) {
	   //   console.log("--> Submitting form");
	   //   var dataObject = {
	   //      name : $scope.myForm.name
	   //      ,car  : $scope.myForm.car
	   //   };

	   //   var responsePromise = $http.post("/angularjs-examples/json-test-data.jsp", dataObject, {});
	   //   responsePromise.success(function(dataFromServer, status, headers, config) {
	   //      console.log(dataFromServer.title);
	   //   });
	   //    responsePromise.error(function(data, status, headers, config) {
	   //      alert("Submitting form failed!");
	   //   });
	   // }










}]);

