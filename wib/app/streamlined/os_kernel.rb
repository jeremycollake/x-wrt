class OsKernelUI < Streamlined::UI
  
end

module OsKernelAdditions
  
end

OsKernel.class_eval {include OsKernelAdditions}
