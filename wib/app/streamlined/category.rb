class CategoryUI < Streamlined::UI
  
end

module CategoryAdditions
  
end

Category.class_eval {include CategoryAdditions}
