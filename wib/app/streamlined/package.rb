class PackageUI < Streamlined::UI

  user_columns :exclude => [:group_master]

end

module PackageAdditions
  
end

Package.class_eval {include PackageAdditions}
