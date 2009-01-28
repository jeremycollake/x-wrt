class KernelUI < Streamlined::UI
  
end

module KernelAdditions
  
end

Kernel.class_eval {include KernelAdditions}
