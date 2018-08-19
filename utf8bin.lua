-- Lua 5.3
utf8bin = {}

function utf8bin.bin_to_utf8(data)
	local pos = 1
	
	data = data:gsub("([\xC2-\xC3])([\x80-\xBF])", function(first, second)
		return utf8.char(first:byte())..utf8.char(second:byte())
	end)
	
	data = data:gsub("\xED([\xA0-\xBF])([\x80-\xBF])", function(first, second)
		return utf8.char(0xED)..utf8.char(first:byte())..utf8.char(second:byte())
	end)
	
	local length, invalid_pos = utf8.len(data, pos)
	
	if length then
		return data
	end
	
	local valid_utf8 = {}
	while not length do
		if invalid_pos > pos then
			table.insert(valid_utf8, data:sub(pos, invalid_pos-1))
		end
		table.insert(valid_utf8, utf8.char(data:byte(invalid_pos)))
		
		pos = invalid_pos + 1
		length, invalid_pos = utf8.len(data, pos)
	end
	if length > 0 then
		table.insert(data:sub(pos))
	end
	
	return table.concat(valid_utf8)
end

function utf8bin.utf8_to_bin(data)
	data = data:gsub("([\xC2-\xC3][\x80-\xBF])", function(chr)
		return string.char(utf8.codepoint(chr))
	end)
	return data
end

return utf8bin