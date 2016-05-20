var TrelloThing = function () {
	var authenticationFailure = function() { console.log("Authentication Failed"); };
	var authenticationSuccess = function() { console.log("Authentication Success"); };

	Trello.authorize({
	  name: "Discovery",
	  // interactive: "false",
	  type: "popup",
	  scope: {
	    read: "true",
	    write: "true" },
	  expiration: "never",
	  success: authenticationSuccess,
	  error: authenticationFailure
	});
	// click on a card and add .json to the end of it
	// find the idList
	var myList = '56fb1b62865d20a5825c7ac2';
	var creationSuccess = function(data) {
	  console.log('Card created successfully. Data returned:' + JSON.stringify(data));
	};

	var newCard = {
	  name: 'New Test Card', 
	  desc: 'This is the description of our new card.',
	  // Place this card at the top of our list 
	  idList: myList,
	  pos: 'top'
	};

	Trello.post('/cards/', newCard, creationSuccess);
}