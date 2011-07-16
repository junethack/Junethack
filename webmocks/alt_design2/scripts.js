// Cheryl Chong
var validationMessage="Thank you";

function isNonempty(anInputValue){
    // if it contains an invalid character
    if (anInputValue.length < 1){
        validationMessage="This field is required.";
        return false;
    } else {
        validationMessage="Thank you.";
        return true;
    }
}

function checkValid(anInput){
/************************************
determines the priority of messages.
the last changed error message is the
one that will be displayed.
************************************/
    var bValid = true;
    if(!isNonempty(anInput.value)){
        bValid = false;
    }
    //$(anInput).next().html(validationMessage); //let's do this with js.
    anInput.parentNode.children[2].innerHTML = validationMessage;
    return bValid;
}

$(document).ready(function(){
    $("input#username").blur(function(){
        checkValid(this);
    });
    $("input#password").blur(function(){
        checkValid(this);
    });
    $("input#confirm").blur(function(){
        checkValid(this);
    });
    // still need to preventdefault form submission
    // need a more elegant way of checking form children.. and both register and login forms.
});