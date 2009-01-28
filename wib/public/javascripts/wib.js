function show_vendor(select) {
  var name = select.options[select.options.selectedIndex].value;
  var divs = document.getElementsByTagName("div");
  for (var i = 0; i <= divs.length; i++) {
    if (divs[i] && divs[i].id.match(/^vendor.*/)) {
      if ((divs[i].id == "vendor_" + name) || (name == "All")) {
	divs[i].style.display = '';
      }
      else {
	divs[i].style.display = 'none';
      }
    }
  }
}
