/* some standard cookie manipulation functions */

/**
 * Sets a Cookie with the given name and value.
 *
 * name       Name of the cookie
 * value      Value of the cookie
 * [expires]  Expiration date of the cookie (default: end of current session)
 * [path]     Path where the cookie is valid (default: path of calling document)
 * [domain]   Domain where the cookie is valid
 *              (default: domain of calling document)
 * [secure]   Boolean value indicating if the cookie transmission requires a
 *              secure transmission
 */
function setCookie(name, value, expires, path, domain, secure) 
{
    document.cookie= name + "=" + escape(value) +
        ((expires) ? "; expires=" + expires.toGMTString() : "") +
        ((path) ? "; path=" + path : "") +
        ((domain) ? "; domain=" + domain : "") +
        ((secure) ? "; secure" : "");
}

/**
 * Gets the value of the specified cookie.
 *
 * name  Name of the desired cookie.
 *
 * Returns a string containing value of specified cookie,
 *   or null if cookie does not exist.
 */
function getCookie(name) 
{
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    if (begin == -1) 
    {
        begin = dc.indexOf(prefix);
        if (begin != 0) return null;
    } 
    else 
    {
        begin += 2;
    }
    var end = document.cookie.indexOf(";", begin);
    if (end == -1) 
    {
        end = dc.length;
    }
    return unescape(dc.substring(begin + prefix.length, end));
}

/**
 * Deletes the specified cookie.
 *
 * name      name of the cookie
 * [path]    path of the cookie (must be same as path used to create cookie)
 * [domain]  domain of the cookie (must be same as domain used to create cookie)
 */
function deleteCookie(name, path, domain) 
{
    if (getCookie(name)) 
    {
        document.cookie = name + "=" +
            ((path) ? "; path=" + path : "") +
            ((domain) ? "; domain=" + domain : "") +
            "; expires=Thu, 01-Jan-70 00:00:01 GMT";
    }
}

/* ************************************************************ */
/* color theme switching code */

function setcolor()
{	
	// set cookie to expire in 30 days
	var expireTime=new Date();
	ThirtyDays=30*24*60*60*1000; 
   	expireTime.setTime(expireTime.getTime()+ThirtyDays);	   	
 	setCookie("webif_colortheme",this.title, expireTime);			
 	colorize();  
  	window.location.reload(true);
}

// find all objects of swatch class and set onclick handler
function swatch()
{
  var divs=document.getElementsByTagName("*");
  var count=0;
  for(var i=0; i < divs.length; i++) 
  {   
    if(divs[i].className.indexOf("swatch") != -1) 
    {    	    	
    	var colorTitle;
    	switch(count)
    	{
    		case 0:
    			colorTitle='green';
    			break;
    		case 1:
    			colorTitle='blue';
    			break;
    		case 2:
    			colorTitle='navyblue';
    			break;    	
    		case 3:
    			colorTitle='white';
    			break;    	
    		case 4:
    		default:    		
    			colorTitle='brown';
    			break;
    	}   
    	divs[i].title=colorTitle; 	
    	divs[i].onclick=setcolor;
    	count++;
    }
  }
}

// set color theme from cookie
function colorize()
{  
  var color=getCookie("webif_colortheme")
  document.write('<link rel="stylesheet" type="text/css" href="');
  switch(color)
  {	
	case 'green':
  		document.write('/color_green.css" />');
  		break;  		  	
  	case 'white':
  		document.write('/color_white.css" />');
  		break;
  	case 'brown':  	  	
  		document.write('/color_brown.css" />');
  		break;
	case 'blue':	
  		document.write('/color_blue.css" />');
  		break;      		
	case 'navyblue':
	default:
  		document.write('/color_navyblue.css" />');
  		break;  				
  }
}