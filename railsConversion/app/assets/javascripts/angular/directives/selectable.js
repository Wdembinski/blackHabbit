  black_Habit.directive('selectable', function () {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
        	// console.log()
            element.bind('click', function(e) {
              $(".selected").each(function() {
                $(this).removeClass('selected');
              });
              element.addClass('selected');
              scope.$apply(attrs.selectable);
            });
        }
    }
});
