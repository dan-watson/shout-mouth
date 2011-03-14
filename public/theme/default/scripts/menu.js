$(document).ready(function() {

    $("#menu > ul > li:has(.child_menu)").mouseenter(function() {    
			width = $(this).width()	
			//Find the max width of children
			child_width = $(this).children(".child_menu").width()
			//Calculate which width to use
			calculated_width = 0
			
			width <= child_width ? calculated_width = child_width : calculated_width = width
			
			$(this).children(".child_menu_item").width(calculated_width);
			$(this).children(".child_menu").width(calculated_width);
			$(this).children(".child_menu").slideDown(300);
    });

	$("#menu > ul > li:has(.child_menu)").mouseleave(function(){
		$(this).children(".child_menu").slideUp(300);
	});

});