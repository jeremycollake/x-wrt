class MaintainerUI < Streamlined::UI
  
end

module MaintainerAdditions
  
end

Maintainer.class_eval {include MaintainerAdditions}
