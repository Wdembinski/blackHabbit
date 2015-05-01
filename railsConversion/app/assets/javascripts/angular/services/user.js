

black_Habit.factory('User', function(CookieStorage, Access_levels){
	var access=function(access_levels,CookieStorage){
		if(user && !user.expired){
			return Access_levels.logged_in_user
		}else{
			return Access_levels.normal_user
		}
	}

	var user=CookieStorage.getItem("user")
	user.expired=function(ttl) { //ttl in minutes
    ttl = typeof a !== 'undefined' ? a : 20;
    var then = CookieStorage.getItem("user").logged_in_time/1000
    var now = new Date();  // Gets the current time
    var nowTs = Math.floor(now.getTime()/1000); // getTime() returns milliseconds, and I want seconds, hence the Math.floor and division by 1000
    var seconds = nowTs-(then);
    if (seconds > 1200) {
       return true;
    }else{
      return false;
    }
  }

	return{
		access:access(),
		userObj:user
	}

});