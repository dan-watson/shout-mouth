$(document).ready(function() {

    var comment_form = $('#commentform');

    comment_form.submit(function() {
			$("#add_comment_submit").val("Saving...")
        	$.post(comment_form.attr('action'),comment_form.serialize(),function(data) {
				
				$(".error").remove();
				//Check For Errors
				if(data[0] != undefined && data[0].hasOwnProperty('error')){
					
					$("#errorTemplate").tmpl(data).appendTo("#commentform")
					$("#add_comment_submit").val("Not Saved...")
					return;
				}
				
				//Add Post To Collection
				$("#commentTemplate").tmpl(data).appendTo(".comments");
				//Update button value
				$("#add_comment_submit").val("Saved...")
			
        	});
			
			return false;
    });
});

