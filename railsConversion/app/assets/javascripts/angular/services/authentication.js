
// black_Habit.factory('Authentication', function($http, LocalService, AccessLevels) {
//   return {
//     authorize: function(access) {
//       if (access === AccessLevels.user) {
//         return this.isAuthenticated();
//       } else {
//         return true;
//       }
//     },
//     isAuthenticated: function() {
//       return LocalService.get('auth_token');
//     },
//     login: function(credentials) {
//       var login = $http.post('/auth/authenticate', credentials);
//       login.success(function(result) {
//         LocalService.set('auth_token', JSON.stringify(result));
//       });
//       return login;
//     },
//     logout: function() {
//       // The backend doesn't care about logouts, delete the token and you're good to go.
//       LocalService.unset('auth_token');
//     },
//     register: function(formData) {
//       LocalService.unset('auth_token');
//       var register = $http.post('/auth/register', formData);
//       register.success(function(result) {
//         LocalService.set('auth_token', JSON.stringify(result));
//       });
//       return register;
//     }
//   };
// });

black_Habit.factory('Auth', function($http, $rootScope, $cookieStore){ 
    var u_email = $cookieStore.get('u_email');
    var logged_in_time = $cookieStore.get('logged_in_time');
    if (typeof u_mail !== 'undefined') {
        $rootScope.logged_in=false;
    } else{
      console.log(u_email)
      console.log(logged_in_time) /////////////////////////// Change stuff based on logged in etc
      // console.log(new Date(logged_in_time))
      return {
        u_email: u_email,
        logged_in: logged_in_time
      }
    }


});

// .factory('Auth', function($http, $rootScope, $cookieStore){

//     var accessLevels = routingConfig.accessLevels
//         , userRoles = routingConfig.userRoles
//         , currentUser = $cookieStore.get('user') || 
//                         { username: '', role: userRoles.public };

//     // ...

//     return {

//         // ...

//         accessLevels: accessLevels,
//         userRoles: userRoles,
//         user: currentUser
//     };

// });