var convTable = {
	/*ř*/ "c345":"%fd",
	/*í*/ "c237":"%a1",
	/*š*/ "c353":"%e7",
	/*ž*/ "c382":"%a7",
	/*ť*/ "c357":"%9c",
	/*č*/ "c269":"%9f",
	/*ý*/ "c253":"%ec",
	/*ů*/ "c367":"%85",
	/*ň*/ "c328":"%e5",
	/*ú*/ "c250":"%a3",
	/*ě*/ "c283":"%d8",
	/*ď*/ "c271":"%d4",
	/*á*/ "c225":"%a0",
	/*é*/ "c233":"%82",
	/*ó*/ "c243":"%a2",
	/*Ř*/ "c344":"%fc",
	/*Í*/ "c205":"%d6",
	/*Š*/ "c352":"%e6",
	/*Ž*/ "c381":"%a6",
	/*Ť*/ "c356":"%9b",
	/*Č*/ "c268":"%ac",
	/*Ý*/ "c221":"%ed",
	/*Ů*/ "c366":"%de",
	/*Ň*/ "c327":"%d5",
	/*Ú*/ "c218":"%e9",
	/*Ě*/ "c282":"%b7",
	/*Ď*/ "c270":"%d2",
	/*Á*/ "c193":"%b5",
	/*É*/ "c201":"%90",
	/*Ó*/ "c211":"%e0",
}

function doClick(srcButton) {
	var statusBox = document.getElementById("status");
	var valueBox = document.getElementById("dispText");
	var value = valueBox.value;
	if (!value) {
		alert("Enter text!");
		return;
	}

	srcButton.disabled = true;
	statusBox.innerHTML = "Sending...";
	var result = "";
	for ( var i = 0; i < value.length; i++ ) {
		var convValue = convTable["c"+value.charCodeAt(i)];
		if (convValue) {
			result += convValue;
		} else {
			if (value.charCodeAt(i) > 255) {
				result += '.';
			} else {
				result += value.charAt(i);
			}
		}
	}

	var anHttpRequest = new XMLHttpRequest();
	anHttpRequest.onreadystatechange = function() { 
		if (anHttpRequest.readyState == 4) { 
			srcButton.disabled = false;
			if (anHttpRequest.status == 200) {
				valueBox.value = "";
				statusBox.innerHTML = "Sent!";
			} else {
				statusBox.innerHTML = "Error while sending: " + anHttpRequest.statusText;
			}
		}
	}
	anHttpRequest.open("GET", "setText?"+result, true);
	try {
		anHttpRequest.send();
	} catch (err) {
		srcButton.disabled = false;
		statusBox.innerHTML = "Error while sending: " + err;
	}
}