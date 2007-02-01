var dragapproved=false
var minrestore=0
var initialwidth,initialheight
var ie5=document.all&&document.getElementById
var ns6=document.getElementById&&!document.all
function iecompattest(){ return (!window.opera && document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}
function drag_drop(e){ if (ie5&&dragapproved&&event.button==1){ document.getElementById("dwindow").style.left=tempx+event.clientX-offsetx+"px"
document.getElementById("dwindow").style.top=tempy+event.clientY-offsety+"px"
}
else if (ns6&&dragapproved){ document.getElementById("dwindow").style.left=tempx+e.clientX-offsetx+"px"
document.getElementById("dwindow").style.top=tempy+e.clientY-offsety+"px"
}
}
function initializedrag(e){ offsetx=ie5? event.clientX : e.clientX
offsety=ie5? event.clientY : e.clientY
tempx=parseInt(document.getElementById("dwindow").style.left)
tempy=parseInt(document.getElementById("dwindow").style.top)
dragapproved=true
document.getElementById("dwindow").onmousemove=drag_drop
}
function loadwindow(url,width,height){ if (!ie5&&!ns6)
window.open(url,"","width=width,height=height,scrollbars=1")
else{ document.getElementById("dwindow").style.display=''
document.getElementById("dwindow").style.width=initialwidth=width+"px"
document.getElementById("dwindow").style.height=initialheight=height+"px"
document.getElementById("dwindow").style.left=screen.width/2 + "px"
document.getElementById("dwindow").style.top=ns6? window.pageYOffset*1+document.body.clientHeight/3-height +"px" : iecompattest().scrollTop*1+document.body.clientHeight/3-height +"px"
}
}
function maximize(){ if (minrestore==0){ minrestore=1
document.getElementById("dwindow").style.width=ns6? window.innerWidth-20+"px" : iecompattest().clientWidth+"px"
document.getElementById("dwindow").style.height=ns6? window.innerHeight-20+"px" : iecompattest().clientHeight+"px"
}
else{ minrestore=0
document.getElementById("dwindow").style.width=initialwidth
document.getElementById("dwindow").style.height=initialheight
}
document.getElementById("dwindow").style.left=ns6? window.pageXOffset+"px" : iecompattest().scrollLeft+"px"
document.getElementById("dwindow").style.top=ns6? window.pageYOffset+"px" : iecompattest().scrollTop+"px"
}
function closeit(){ document.getElementById("dwindow").style.display="none"
}
function stopdrag(){ dragapproved=false; document.getElementById("dwindow").onmousemove=null;}
