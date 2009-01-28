class BoardUI < Streamlined::UI
  
end

module BoardAdditions
  
end

Board.class_eval {include BoardAdditions}
