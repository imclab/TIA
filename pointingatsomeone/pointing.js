var myLat;
var myLng;
var dlat;
var dlng;
var heading;
var bearing;
var accuracy;

var ID;
var yourID;

window.addEventListener('load', function() {

	Parse.initialize("oQcxap8X48yinv2iH3VqXZnztrNGZjDpytGdfobc", "WpTYBcqLa2CKOBrjJtwmfCopncbmCK48wrPs54MS");

	ID=Math.floor(Math.random()*10000);


	//signIn();


	var compass = document.body.appendChild(document.createElement('article'));
	compass.id='compass';

	var spinner = compass.appendChild(document.createElement('article'));
	spinner.id='spinner';
	var pin = spinner.appendChild(document.createElement('article'));
	pin.id='pin';


	var line = spinner.appendChild(document.createElement('article'));
	line.id='line';

		//North arrow
	    var main = ((0 % 2)?'':' main');
	    point = spinner.appendChild(document.createElement('label'));
	    point.className='point' + main;
	    point.innerText = 'N';
	    point.style.webkitTransform = 'rotateZ(' + (0 * 45) + 'deg)'
	    arrow = spinner.appendChild(document.createElement('div'));
	    arrow.className='arrow' + main;
	    arrow.style.webkitTransform = 'rotateZ(' + (0 * 45) + 'deg)'


	    line = spinner.appendChild(document.createElement('div'));
	    line.className='line';
	    line.style.webkitTransform = 'rotateZ(' + (180) + 'deg)'




	//smooth spinning
	var lastHeading = 0;
	window.addEventListener('deviceorientation', function(e) {
	    heading = e.webkitCompassHeading + window.orientation;
	    if (Math.abs(heading - lastHeading)<180) {
	        spinner.style.webkitTransition = 'all 0.2s ease-in-out';
	    } else {
	        spinner.style.webkitTransition = 'none';
	    }
	    spinner.style.webkitTransform = 'rotateZ(-' + heading + 'deg)';
	    lastHeading = heading;
	}, false);
	
	document.body.addEventListener('touchstart', function(e) {
	    e.preventDefault();
	}, false);
	
	window.addEventListener('orientationchange', function(e) {
	    window.scrollTo(0,1);
	}, false);
	
	setTimeout(function () {window.scrollTo(0,1);}, 0);

	getYourPosition();
	setInterval(getYourPosition,10000);




	//GPS
 	//Register for location changes
    var watchId = navigator.geolocation.watchPosition(handler, handleError);
    function handleError(error) {
      // Update a div element with the error message
    }

}, false);




function signIn(){
	var currentUser = Parse.User.current();
	if (currentUser) {
	    // do stuff with the user
	} else {
	    // show the signup or login page
	signUp();
	
	}


}

function signUp(){
	
	
	var user = new Parse.User();
	user.set("username", "hello");
	user.set("description1", "beans");
	user.set("description2", "cake");
	user.set("description3", "trees");
	
	
	user.signUp(null, {
	success: function(user) {
	// Hooray! Let them use the app now.
	},
	error: function(user, error) {
	// Show the error message somewhere and let the user try again.
	alert("Error: " + error.code + " " + error.message);
	}
	});



}


function handler(location) {
	myLat=location.coords.latitude;
	myLng=location.coords.longitude;
	accuracy=location.coords.accuracy;
	
	savePosition();
	getBearing();
	updateStats();

}

function updateStats(){


var stats = document.getElementById("stats");
	stats.innerHTML="";
	stats.innerHTML+="<p>myID: " + ID + "</p>";
	stats.innerHTML+="<p>myLat: " + myLat + "</p>";
	stats.innerHTML+="<p>myLng: " + myLng + "</p>";
	stats.innerHTML+="<p>Accuracy: " + accuracy + "</p>";

	stats.innerHTML+="<p>yourID: " + yourID + "</p>";
	stats.innerHTML+="<p>dlat: " + dlat + "</p>";
	stats.innerHTML+="<p>dlng: " + dlng + "</p>";

	stats+="<p>Bearing: " + bearing + "</p>";
}



function savePosition(){

		var Pos = Parse.Object.extend("Position");
		var pos = new Pos();
		 
		pos.set("ID", ID);
		pos.set("lat", myLat);
		pos.set("lng", myLng);
		 
		pos.save(null, {
		  success: function(pos) {
		    // Execute any logic that should take place after the object is saved.
		    console.log('New object created with objectId: ' + pos.id);
		  },
		  error: function(pos, error) {
		    // Execute any logic that should take place if the save fails.
		    // error is a Parse.Error with an error code and description.
		    console.log('Failed to create new object, with error code: ' + error.description);
		  }
		});
}







function getYourPosition(){

	var Pos = Parse.Object.extend("Position");
	var query = new Parse.Query(Pos);
	
	
	query.descending("updatedAt");
	query.notEqualTo("ID", ID);
	query.first({
	  success: function(object) {
	    // Successfully retrieved the object.
			yourID=object.get('ID');
			dlat=object.get('lat');
			dlng=object.get('lng');
			console.log("your ID:"+yourID);
			console.log("yourlat:"+dlat);
			console.log("yourlng:"+dlng);

	  },
	  error: function(error) {
	    alert("Error: " + error.code + " " + error.message);
	  }
	});



    
//north

//west
//dlat=35.537189;
//dlng=139.560898;


getBearing();

updateStats();

}




function getBearing()
{




    var _lat1 = myLat;
    var _lng1 = myLng;
    var _lat2 = dlat;
    var _lng2 = dlng;
    
    var lat1 = Math.radians(_lat1);
    var lat2 = Math.radians(_lat2);
    var dLon = Math.radians(_lng2) - Math.radians(_lng1);
	
    var y = Math.sin(dLon) * Math.cos(lat2);
    var x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
	var brng = Math.atan2(y, x);
    bearing=(Math.degrees(brng) + 360) % 360;


    	    line.style.webkitTransform = 'rotateZ(' + (180+bearing) + 'deg)'
    	    //line.style.webkitTransformOrigin = '100%,40%)';

}



// Converts from degrees to radians.
Math.radians = function(degrees) {
  return degrees * Math.PI / 180;
};
 
// Converts from radians to degrees.
Math.degrees = function(radians) {
  return radians * 180 / Math.PI;
};






