/* this script swiped from openwrt.org */
function GetCookie (name) {  
  var arg = name + "=";  
  var alen = arg.length;  
  var clen = document.cookie.length;  
  var i = 0;  
  while (i < clen) {    
    var j = i + alen;    
    if (document.cookie.substring(i, j) == arg)      
      return getCookieVal (j);    
    i = document.cookie.indexOf(" ", i) + 1;    
    if (i == 0) break;   
  }  
  return null;
}

function SetCookie (name, value) {  
  var argv = SetCookie.arguments;  
  var argc = SetCookie.arguments.length;  
  var expires = (argc > 2) ? argv[2] : null;  
  var path = (argc > 3) ? argv[3] : null;  
  var domain = (argc > 4) ? argv[4] : null;  
  var secure = (argc > 5) ? argv[5] : false;  
  document.cookie = name + "=" + escape (value) + 
  ((expires == null) ? "" : ("; expires=" + expires.toGMTString())) + 
  ((path == null) ? "" : ("; path=" + path)) +  
  ((domain == null) ? "" : ("; domain=" + domain)) +    
  ((secure == true) ? "; secure" : "");
}

function getCookieVal(offset) {
  var endstr = document.cookie.indexOf (";", offset);
  if (endstr == -1)
    endstr = document.cookie.length;
  return unescape(document.cookie.substring(offset, endstr));
}

function clickswatch() {
  var exp = new Date(); 
  exp.setTime(exp.getTime() + (24 * 60 * 60 * 1000 * 31 * 9)); 
  if (this==document.getElementById("colorize")) {
    SetCookie("bgcolor","",exp,null,".webif")
  } else {
    SetCookie("bgcolor",this.style.backgroundColor,exp,null,".webif")
  }
  colorize();
}

function swatch(){
  var divs=document.getElementsByTagName("*");
  for(var i=0; i < divs.length; i++) {
    if(divs[i].className.indexOf("swatch") != -1) {
      divs[i].onclick=clickswatch
    }
  }
}

function colorize(){
  var message=new Date()
  var h=message.getHours()
  var color=GetCookie("bgcolor")
  if (color) {
    // nothing
  } else if (h>=7 && h<18) {
    color='#557788'
  } else if (h>=6 && h<20) {
    color='#114488'
  } else if (h>=5 && h<23) {
    color='#192a65'
  } else {
    color='#334444'
  }
  document.body.style.backgroundColor=color
}