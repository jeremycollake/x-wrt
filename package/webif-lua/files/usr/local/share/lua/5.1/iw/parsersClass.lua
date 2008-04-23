parsersClass = {} 
parsersClass_mt = {__index = parsersClass} 

function parsersClass.new (file) 
	local self = {}
	setmetatable(self,parsersClass_mt) 
  self.UCI = uciClass.new(file)
--	self:Init(file)
	return self 
end 

function parsersClass:init()

end

function parsersClass:depends(pkgs_list)
  return ""
end

function pasrsersClass:process()
  local str = ""
  for i=1, #self.UCI.sections do
    for k,v in pairs(self.UCI.sections[i].values) do
      str = str .. k .. "=" .. v .. "\n"
    end 
  end
  return str    
end

