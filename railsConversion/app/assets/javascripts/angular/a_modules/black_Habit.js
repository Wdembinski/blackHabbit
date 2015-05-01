var black_Habit= angular.module('black_Habit', ['ngCookies','ui.bootstrap','ui.router']);

black_Habit.config(function($stateProvider,$urlRouterProvider){
	// $urlRouterProvider.otherwise('/');
	$stateProvider
			.state('User',{
				url:':username',
				views: {
					"test1": {
					    templateUrl: "home.viewA"
					},
					"test2": {
					    templateUrl: "home.viewB"
					}

				}
			})
	    .state('Home', {
	        url: "",
	        views: {
	            "viewA": {
	                templateUrl: "home.viewA"
	            },
	            "viewB": {
	                templateUrl: "home.viewB"
	            }
	        }
	    })
	    .state('Tags', {
	        url: "Tags",
	        views: {
	            "viewA": {
	                templateUrl: "tags.viewA"
	            },
	            "viewB": {
	                templateUrl: "tags.viewB"
	            }
	        }
	    })
	    .state('Something', {
	        url: "Something",
	        views: {
	            "viewA": {
	                templateUrl: "something.viewA"
	            },
	            "viewB": {
	                templateUrl: "something.viewB"
	            }
	        }
	    })
	})

