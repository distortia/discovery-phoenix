var githubExport = function(id){
	var selectedValue = document.getElementById("repo_name")[document.getElementById("repo_name").selectedIndex].value;
	var csrf = document.querySelector("meta[name=csrf]").content;
	$.ajax({
		type: "POST",
		headers: {
        	"X-CSRF-TOKEN": csrf 
    	},
		url:"/tickets/"+id+"/github_export?details="+selectedValue,
		success: function(data, status){
			if(data){
				alert("Incident Created!");
				window.location.href = "/tickets/"+id;
			}
		}
	});
};