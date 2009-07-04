function user_level_select (form,conffile,default,maxlevel,confsection,confuserlevel)
	local confsection = confsection or "webadmin"
	local confuserlevel = confuserlevel or "userlevel"
	local default = default or 1
	local maxlevel = maxlevel or 4
	local uci_var = conffile.."."..confsection.."."..confuserlevel
	
  	form:Add("select",uci_var,uci.check_set(conffile,confsection,confuserlevel,default),tr("all_user_level#User Level"),"string")
    form[uci_var].options:Add("0","Select Mode")
    form[uci_var].options:Add("1","Beginer")
	if maxlevel > 2 then
		form[uci_var].options:Add("2","Medium")
	end
	if maxlevel > 2 then
		form[uci_var].options:Add("3","Advanced")
	end
	if maxlevel > 3 then
		form[uci_var].options:Add("4","Expert")
	end
    form:Add_help(tr("all_user_level#User Level"),tr("all_help_user_level#"..[[
          <strong>Beginer :</strong>
          This basic mode write the propers configuration files.
		  ]]))
--          <br /><br />
--          <strong>Expert :</strong><br />
--          This mode keep your configurations file and you edit they by your self.
--          ]]))
end

function service_state_select (form,conffile,default,confsection,confenable)
	local confsection = confsection or "webadmin"
	local conf_var = conf_var or "enable"
	local default = default or 0
	local uci_var = conffile.."."..confsection.."."..conf_var
	
  	form:Add("select",uci_var,uci.check_set(conffile,confsection,conf_var,default),tr("all_service_state#Service State"),"string")
    form[uci_var].options:Add("0","Disable")
    form[uci_var].options:Add("1","Enable")
    form:Add_help(tr("all_service_state#Service State"),tr("all_help_service_enable#"..[[
          Enable or Disable service.
          ]]))
end

