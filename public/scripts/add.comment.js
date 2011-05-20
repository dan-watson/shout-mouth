$(document).ready(function() {

    var comment_form = $('#commentform');

    comment_form.submit(function() {
      $.blockUI({ css: { 
                        border: 'none', 
                        padding: '15px', 
                        backgroundColor: '#000', 
                        '-webkit-border-radius': '10px', 
                        '-moz-border-radius': '10px', 
                        opacity: .5, 
                        color: '#FFFFFF' 
                        }
                      });
      
      $.post(comment_form.attr('action'),comment_form.serialize(),function(data) {
				$(".error").remove();
				//Check For Errors
				if(data[0] != undefined && data[0].hasOwnProperty('error')){		
					$("#errorTemplate").tmpl(data).appendTo("#commentform")
          $.unblockUI();
					return;
				}				
				//Add Post To Collection
				$("#commentTemplate").tmpl(data).appendTo(".comments");
        $.unblockUI();
      });
			return false;
    });
});

