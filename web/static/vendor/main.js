$(function(){
	changeLink();
	$("#repo_name").change(function(){
		changeLink();
	})
})

var changeLink = function(){
	var link = $('#export_github_link').attr("href");
	$('#export_github_link').attr("href", link.split('details=')[0] + 'details=' + document.getElementById("repo_name")[document.getElementById("repo_name").selectedIndex].value);	
}