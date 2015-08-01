black_Habit.factory('Authentication', function($location,User,$state,$http, $rootScope, CookieStorage, Access_levels){ 
  return{
    authorize: function() {
      if (!User.expired()) {   //just a place holder for now.  Need to use this authorize thing w. roles maybe
      // if (User.access === Access_levels.logged_in_user) {
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

    //seems redundant
    isAuthenticated: function() {
      return CookieStorage.getItem('secure_session');
    },




    
    login: function(credentials) {
      console.log(credentials)

      var login = $http.post('/login', credentials);
      login.success(function(result) {
        var user=CookieStorage.getItem("user")
        $state.go('logged_in.Home');
        console.log($state.current)
        console.log("Succesful Login: ",result)


      });

      login.error(function(result){
        console.log($state.current);
        console.log("Failed to Login: ",result);
      });
    //   $scope.changeState = function () {    TODO:CHANGE STATE to /:username when logged in
    // $state.go('where.ever.you.want.to.go');
    //   };
      return login;
    },



    logout: function() {
      CookieStorage.clear()
      // The backend shouldnt care about logouts, delete the token and I be good
      $state.go("/")
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
