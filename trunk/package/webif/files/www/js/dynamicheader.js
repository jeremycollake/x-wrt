//###################################################################
//# dynamicheader.js
//#
//# Description:
//#		Gets data for the dynamic header
//#
//# Author(s) [in order of work date]:
//#       m4rc0 <jansssenmaj@gmail.com>
//#
//# Major revisions:
//#		Initial release 2008-11-29
//#
//# NVRAM variables referenced:
//#       none
//#
//# Configuration files referenced:
//#       none
//#
//# Required components:
//# 

var x = (window.ActiveXObject) ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest();

function getdateinfo()
{
	if(x)
     {
          x.onreadystatechange = function()
          {
               if (x.readyState == 4 && x.status == 200)
               {
                    var arr_DateTime = x.responseText.split('|');
					
                    document.getElementById ('d_time').innerHTML = arr_DateTime[0];
                    document.getElementById ('d_date').innerHTML = arr_DateTime[1];
                    document.getElementById ('d_uptime').innerHTML = arr_DateTime[2];
                    document.getElementById ('d_loadavg').innerHTML = arr_DateTime[3];
               }
          }
          x.open ("GET", 'getdata.sh', true);
          x.send (null);
		  
		  setTimeout ("getdateinfo()", 1000);
     }
    else
     {
         alert ('Script or compatibility error, aborting script...');
     }
     
}

getdateinfo();