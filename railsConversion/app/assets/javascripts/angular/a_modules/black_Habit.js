var black_Habit= angular.module('black_Habit', ['templates','ngCookies','ui.bootstrap','ui.router']);

black_Habit.constant('USER_ROLES', {
  all: '*',
  admin: 'admin',
  editor: 'editor',
  guest: 'guest'
})



black_Habit.constant('AUTH_EVENTS', {
  loginSuccess: 'auth-login-success',
  loginFailed: 'auth-login-failed',
  logoutSuccess: 'auth-logout-success',
  sessionTimeout: 'auth-session-timeout',
  notAuthenticated: 'auth-not-authenticated',
  notAuthorized: 'auth-not-authorized'
})


black_Habit.config(function($stateProvider,$urlRouterProvider,USER_ROLES){
	$urlRouterProvider.otherwise('/');
	$stateProvider
    .state('/', {  
    		// abstract:true,
        url: "",
        views: {
            "header_view": {
                templateUrl:"login_form.html",
            }
        }
    })
    .state('logged_in', {  //need t come up with the nested views logged_in.tags etc
    		// abstract:true,
        url: "/user",

        views: {
        		"main_container":{
        			templateUrl:"searches.html"
        		},
            "header_view": {
              templateUrl: "logout_form.html",
            },
            "viewA":{
            	template:"TESTSTESTESSETSET",
            },
            "viewA": {
              template: "something.viewB.html"
            }
        },
        data: {
          authorizedRoles: [USER_ROLES.admin, USER_ROLES.editor]
        }
    }).state('logged_in.Home',{
    	views:{
    		"viewA":{
    			templateUrl:"home.viewB.html",
    		}
    	}
    }).state('logged_in.Tags',{
    	views:{
    		"viewA":{
    			template:"TAGSS",
    		}
    	}
    }).state('logged_in.Something',{
    	views:{
    		"viewA":{
    			template:"Something",
    		}
    	}
    })

			// .state('User',{
			// 	url:':username',
			// 	access:{
			// 		requiresLogin: true
			// 	},
			// 	views: {
			// 		"test1": {
			// 		    templateUrl: "home.viewA"
			// 		},
			// 		"test2": {
			// 		    templateUrl: "home.viewB"
			// 		}

			// 	}
			// })
	  //   .state('Home', {
	  //       url: "",
	  //       views: {
	  //           "viewA": {
	  //               templateUrl: "home.viewA"
	  //           },
	  //           "viewB": {
	  //               templateUrl: "home.viewB"
	  //           }
	  //       }
	  //   })
	  //   .state('Tags', {
	  //       url: "Tags",
	  //       views: {
	  //           "viewA": {
	  //               templateUrl: "tags.viewA"
	  //           },
	  //           "viewB": {
	  //               templateUrl: "tags.viewB"
	  //           }
	  //       }
	  //   })

	})


// black_Habit.run(function ($rootScope) {

//   $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {
//     var requireLogin = toState.data.requireLogin;

//     if (requireLogin && typeof $rootScope.currentUser === 'undefined') {
//       event.preventDefault();
//       // get me a login modal!
//     }
//   });

// });




// black_Habit.run(function ($rootScope, AUTH_EVENTS, Authentication) {
//   $rootScope.$on('$stateChangeStart', function (event, next) {
    // var authorizedRoles = next.data.authorizedRoles;
//     if (!AuthService.isAuthorized(authorizedRoles)) {
//       event.preventDefault();
//       if (AuthService.isAuthenticated()) {
//         // user is not allowed
//         $rootScope.$broadcast(AUTH_EVENTS.notAuthorized);
//       } else {
//         // user is not logged in
//         $rootScope.$broadcast(AUTH_EVENTS.notAuthenticated);
//       }
//     }
//   });
// })







black_Habit.controller('black_Habit', function ($scope,USER_ROLES,Authentication) {
  $scope.currentUser = null;
  $scope.userRoles = USER_ROLES;
  $scope.isAuthorized = Authentication.authorize;
 
  $scope.setCurrentUser = function (user) {
    $scope.currentUser = user;
  };
})