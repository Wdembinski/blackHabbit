black_Habit.factory('Authentication', function(User,$state,$http, $rootScope, CookieStorage, Access_levels){ 
  console.log(User)
  return{
    authorize: function(access) {
      if (User.access === Access_levels.logged_in_user) {
        return true;

        // return this.isAuthenticated();
      } else {
        return false;
      }
    },
    logged_in: function($cookieStore){
      if (typeof($cookieStore.get.user.type) != "undefined" && !user.expired(20)){
        return true
      }else{
        return false
      }
    },
    isAuthenticated: function() {
      return CookieStorage.get('secure_session');
    },
    login: function(credentials) {
      var login = $http.post('/login', credentials);
      login.success(function(result) {
        CookieStorage.set_item('secure_session', JSON.stringify(result));
      });
      login.error(function(result){
        console.log("FAILURE",result);
      })
    //   $scope.changeState = function () {    TODO:CHANGE STATE to /:username when logged in
    // $state.go('where.ever.you.want.to.go');
    //   };
      console.log(login)
      return login;
    },
    logout: function() {
      // The backend doesn't care about logouts, delete the token and you're good to go.
      CookieStorage.unset('secure_session');
    },
    register: function(formData) {
      CookieStorage.unset('secure_session');
      var register = $http.post('/auth/register', formData);
      register.success(function(result) {
        CookieStorage.set_item('secure_session', JSON.stringify(result));
      });
      return register;
    },

  }
});
