class FeatureUI < Streamlined::UI
  
end

module FeatureAdditions
  
end

Feature.class_eval {include FeatureAdditions}
