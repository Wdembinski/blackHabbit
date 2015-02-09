
var black_Habit= angular.module('black_Habit', []);

black_Habit.controller('resultCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('/testSearch.json').success(function(a) {
      $scope.results = a;
    });
    $scope.orderProp = 'name';
  }]);
// black_Habit.controller('resultCtrl', function ($scope) {
//   $scope.results = [
//     {
//     "name" : "d/dot-bit",
//     "value" : "{\"info\":{\"description\":\"Dot-BIT Project - Official Website\",\"registrar\":\"http://register.dot-bit.org\"},\"fingerprint\":[\"30:B0:60:94:32:08:EC:F5:BE:DF:F4:BB:EE:52:90:2C:5D:47:62:46\"],\"ns\":[\"ns0.web-sweet-web.net\",\"ns1.web-sweet-web.net\"],\"map\":{\"\":{\"ns\":[\"ns0.web-sweet-web.net\",\"ns1.web-sweet-web.net\"]}},\"email\":\"register@dot-bit.org\"}",
//     "expires_in" : 7008
//     },
//     {
//     "name" : "d/dot-com",
//     "value" : "BM-5oDW5JuVckVnSDSdcMxySi5cNTadThf",
//     "expires_in" : 34783
//     },
//     {
//     "name" : "d/dot2dot",
//     "value" : "BM-2cVtRVEymDzmCSWvNe4iPUDzne86JuVnmp",
//     "expires_in" : 26793
//     },
//     {
//     "name" : "d/dota2vo",
//     "value" : "BM-2cVtRVEymDzmCSWvNe4iPUDzne86JuVnmp",
//     "expires_in" : 26801
//     }
//     ];

//   $scope.orderProp = 'name';
// });




// blackHabbit.controller('ResultDatailCtrl', ['$scope', '$routeParams', 'result',
//   function($scope, $routeParams, result) {
//     $scope.result = result.get({resultId: $routeParams.resultId}, function(result) {
//       $scope.mainImageUrl = result.images[0];
//     });

//     $scope.setImage = function(imageUrl) {
//       $scope.mainImageUrl = imageUrl;
//     }
//   }]);