require("uci")

function uci.get_all_types(p)
  local sections = {}
  p = uci.get_all(p)
  for i, v in pairs(p) do
    if sections[v[".type"]] == nil then sections[v[".type"]] = {} end
    sections[v[".type"]][#sections[v[".type"]]+1] = {}
    for k, o in pairs(v) do
      sections[v[".type"]][#sections[v[".type"]]][k] = o
    end
  end
  return sections
end

function uci.get_type(p,s)
  local sections = {}
  if string.find(p,".") > 0 and s == nil then
    p,s = unpack(string.split(p,"."))
  end
  p = uci.get_all(p)
  for i, v in pairs(p) do
    if v[".type"] == s then
      sections[#sections+1] = {}
      for k, o in pairs(v) do
        sections[#sections][k] = o
      end
    end
  end
  return sections
end

function uci.get_section(p,s)
  local t = uci.get_all(p)
  return t[s]
end
     