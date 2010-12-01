#!/usr/bin/lua
henv = io.popen("env")
for line in henv:lines() do
	if line:sub(1,3) == "LT_" then
		print(line);
	end
end
henv:close()
print("")
