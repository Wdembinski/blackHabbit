

black_Habit.factory('User', function(CookieStorage, Access_levels){
	var user={}
	// var user=CookieStorage.getItem("user")
	user.expired=function(ttl) { //ttl in minutes
    ttl = typeof a !== 'undefined' ? a : 20;
    var then = CookieStorage.getItem("user").logged_in_time/1000

    console.log("###############--Unix Time Stamp (login time)--################")
    console.log(then)
    if(isNaN(then)){
    	console.log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    	return true;
    }else{
    	var now = new Date();  // Gets the current time
    	var nowTs = Math.floor(now.getTime()/1000);
    	var seconds = nowTs-(then);
      console.log("###############-- Time remaining in session --################")
    	console.log(seconds)
    	if (seconds > 1200) {
    	   return true;
    	}else{
    	  return false;
    	}
    }

  }
  user.active=function(){
  	userCookie = CookieStorage.getItem("user")
  	console.log(userCookie)
		if(!user.expired()){
		// if(user && user.expired){
			true
			// return Access_levels.logged_in_user
		}else{
			false
			// return Access_levels.normal_user
		}
	}

	return user

});