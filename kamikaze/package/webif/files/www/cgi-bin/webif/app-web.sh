#!/usr/bin/webif-page
<?
# add haserl args in double quotes it has very ugly
# command line parsing code!
?>


<html>
<head>
<style type="text/css">
.balloonstyle{
position:absolute;
top: -500px;
left: 0;
padding: 5px;
visibility: hidden;
border:1px solid black;
font:normal 12px Verdana;
line-height: 18px;
z-index: 100;
background-color: white;
width: 200px;
/*Remove below line to remove shadow. Below line should always appear last within this CSS*/
filter: progid:DXImageTransform.Microsoft.Shadow(color=gray,direction=135,Strength=5);
}

#arrowhead{
z-index: 99;
position:absolute;
top: -500px;
left: 0;
visibility: hidden;
}

</style>

<script type="text/javascript" src="/js/balloontip.js">
</script>
</head>


<body>
<center>
<table width="98%" border="0" cellspacing="1" >

  <tr class='wifiscanrow'>
      <td><center><a href="" rel="b1"><img src="/images/app-4.jpg" border="0" ></a><br>Apache Webserver</center></td>
      <td><div align="center"><a href="" rel="b2"><img src="/images/app-6.jpg" border="0" ></a><br>FTP Server</div></td>
      <td><div align="center"><a href="" rel="b3"><img src="/images/app-7.jpg" border="0" ></a><br>MySQL Server</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<div id="b1" class="balloonstyle">
Apache Web server 1.3.3 - Powerfull webserver to serve webpages on World Wide Web.
</div>

<div id="b2" class="balloonstyle">
ProFTPD ?.? - Powerfull FTP server for sharing files globally.
</div>

<div id="b3" class="balloonstyle">
MySQL 4.3 - Massive database server
</div>
</center>
</body>
</html>
