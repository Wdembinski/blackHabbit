black_Habit.factory('CookieStorage', ['$cookieStore', function($cookieStore) {
// black_Habit.factory('CookieStorage', ['$q', '$http', '$cookieStore', function($q, $http, $cookieStore) {

   return {
       getItem: function(item){
          var data = $cookieStore.get(item);
          if (!data){
             data = {};
             return false;
          }else{
             return data;
          }
       },
       setItem: function(key, value){
           $cookieStore.put(key, value);
           return true;
       },
       removeItem: function(key){
           $cookieStore.remove(key);
           return true;
       },
       clear: function() {
           $cookieStore.remove('user');
           $cookieStore.remove('secure_session');
       },
   };
}])