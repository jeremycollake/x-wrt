class DeviceUI < Streamlined::UI
  
end

module DeviceAdditions
  
end

Device.class_eval {include DeviceAdditions}
