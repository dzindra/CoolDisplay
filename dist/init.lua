local function unescape(s)
	local rt, i, len = "", 1, #s
	s = s:gsub('+', ' ')
	local j, xx = s:match('()%%(%x%x)', i)
	while j do
		rt = rt .. s:sub(i, j-1) .. string.char(tonumber(xx,16))
		i = j+3
		j, xx = s:match('()%%(%x%x)', i)
	end
	return rt .. s:sub(i)
end

local currentText = ""

local function setText(text)
	uart.write(0, "\004\001\C1X\023")
	if text then
		currentText = unescape(text)
		uart.write(0, currentText)
	end
end

local function webserver()
	local web = require("web")
	web.callbacks["setText"] = function (conn, fname, ftype, text)
		web.sendResponseHeader(conn, "200 OK", "text/plain")
		setText(text)
	end
	web.callbacks["getText"] = function (conn, fname, ftype, text)
		web.sendResponseHeader(conn, "200 OK", "text/plain")
		conn:send(currentText)
	end
	web.start()
end

setText("    Cool Display")
tmr.alarm(1,1000, 1, function()
	local status = wifi.sta.status()
	if status == 5 then
		tmr.stop(1)
		setText("    Cool Display    IP: " .. wifi.sta.getip())
		webserver()
	else
		setText("    Cool Display    Neni IP / status: " .. status)
	end
end)
