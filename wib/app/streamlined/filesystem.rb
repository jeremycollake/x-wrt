class FilesystemUI < Streamlined::UI
  
end

module FilesystemAdditions
  
end

Filesystem.class_eval {include FilesystemAdditions}
