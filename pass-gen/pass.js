function generate() {
	var quantity = document.getElementById("quantity").value;
	var length = document.getElementById("length").value;
	var lowercase = new Array();
	var uppercase = new Array();
	var numbers = new Array();
	var symbols = new Array();                              

	if(document.getElementById("lowercase").checked==true) {
		lowercase = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
	}

	if(document.getElementById("uppercase").checked==true) {
		uppercase = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]; 
	}
	if(document.getElementById("numbers").checked==true) {
		numbers = ["0","1","2","3","4","5","6","7","8","9"];
	}
	if(document.getElementById("symbols").checked==true) {
		if(document.getElementById("mysql").checked==true) {
			symbols = ["!","@","#","$","^","&","*","(",")","-","+","=","[","]","{","}","|","?","<",">",];
		} else {
			//symbols = ["!","@","#","$","%","^","&","*","(",")","-","_","+","=","[","]","{","}","|","\\","/","?","<",">",",","."];
			symbols = ["(", ")", ".", "&", "@", "?", "'", "#", ",", "/", "\"", "+"];
		}
	}

                                
	var alpha = lowercase.concat(uppercase,numbers);
	var charset = alpha.concat(symbols);
	var limit = charset.length;

	document.getElementById('passwords').innerHTML=""; // clear contents

	for(j=0;j<quantity;j++) {
		for(i=0;i<length;i++) {
			document.getElementById('passwords').innerHTML+=(charset[Math.floor(Math.random()*limit)]);
		}
		document.getElementById('passwords').innerHTML+="<br /><br />";
	}
}
