-- 参数指定哪些移除
--[[
变化项是
47a48
67d67
2c2
这样的，分别是add，delete，change项
#arg个数 arg[1]
-d		 	所有的delete项移除
-d:regex	符合正则表达式的delete项移除

下面的同原理
-a
-a:regex
-c
-c:regex
]]

local instruction = {}
for i = 2, #arg do
	local _1, _, _2 = string.match(arg[i], '([acd])(:?)([^ ]*)')
	if _1 then
		instruction[_1] = instruction[_1] or {}
		if _2 ~= '' then
			table.insert(instruction[_1], _2)
		end
	end
end

if #arg <= 1 then
	instruction['d'] = {}
end

function process_diff(path)
    local need = true
    local file = io.open (path, 'r')
	if file == nil then return end

	local tbl = {}
    for line in file:lines() do
		local cmd = string.match(line, '^[%d,]+([acd])[%d,]+')
		if cmd then
			table.insert(tbl, {})
		end
		
		table.insert(tbl[#tbl], line)
    end
	
	-- 开始倒序处理
	for i = #tbl, 1, -1 do
		local cmd = string.match(tbl[i][1], '^[%d,]+([acd])[%d,]+')
		if instruction[cmd] ~= nil then
			if #instruction[cmd] == 0 then	-- 全部删掉
				table.remove(tbl, i)
			else
				-- 所有行都匹配
				local all_fit = true
				for _i = 2, #tbl[i] do
					local fit = false
					for _, _j in ipairs(instruction[cmd]) do
						if string.match(tbl[i][_i], _j) then
							fit = true
							break
						end
					end
					
					if not fit then
						all_fit = false
					end
				end
				if all_fit then
					table.remove(tbl, i)
				end
			end
		end
	end
    file:close()
	
	local block = {}
	for _, unit in ipairs(tbl) do
		table.insert(block, table.concat(unit, '\n'))
	end
	
	file = io.open (path, 'w')
	file:write(table.concat(block, '\n') .. '\n')
	file:close()
end

process_diff(arg[1])