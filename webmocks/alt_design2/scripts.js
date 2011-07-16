// Cheryl Chong
var validationMessage="Thank you";

function trimAll(strValue) {
/************************************************
DESCRIPTION: Removes leading and trailing spaces.
PARAMETERS: Source string from which spaces will
    be removed;
RETURNS: Source string with whitespaces removed.
*************************************************/
    var objRegExp = /^(\s*)$/;
    //check for all spaces
    if(objRegExp.test(strValue)) {
       strValue = strValue.replace(objRegExp, '');
       if( strValue.length == 0)
          return strValue;
    }
    //check for leading & trailing spaces
    objRegExp = /^(\s*)([\W\w]*)(\b\s*$)/;
    if(objRegExp.test(strValue)) {
        //remove leading and trailing whitespace characters
        strValue = strValue.replace(objRegExp, '$2');
        }
    return strValue;
}

function isNonempty(anInputValue){
    var trimmed = trimAll(anInputValue);
    validationMessage="Thank you.";
    if (trimmed.length < 1){
        validationMessage="This field is required.";
        return false;
    } else {
        return true;
    }
}

function checkValid(anInput){
/*****************************************************************
Determines the priority of messages. The last changed error 
message is the one that will be displayed.
******************************************************************/
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