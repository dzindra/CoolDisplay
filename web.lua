local moduleName = ... or "web"

local M = {}
_G[moduleName] = M

M.extmap = {
    txt = "text/plain",
    htm = "text/html",
    html = "text/html",
    gif = "image/gif",
    jpg = "imge/jpeg",
    png = "image/png",
    lua = "text/html",
    ico = "image/x-icon",
}
M.reqTypes = {
    GET = true,
    POST = true
}
M.callbacks = {
}
M.indexFile = "index.html"
M.defaultContentType = "text/plain"

local function sendFileContents(conn)
    local line = file.read(128)
    while line ~= nil do
        conn:send(line)
        line = nil
        line = file.read(128)
    end
end

function M.sendResponseHeader(conn, code, type)
	conn:send("HTTP/1.1 " .. code .. "\r\nConnection: close\r\nServer: eLua-miniweb\r\nContent-Type: " .. type .. "\r\n\r\n")
end

local function onReceive(conn, request)
    _, _, method, req = string.find(request, "([A-Z]+) (.+) HTTP/1.1")

    if M.reqTypes[method] then
        local fname, ftype

        fname, reqParam = select(3, req:find("(.*)%?(.*)"))
        fname = fname or req
        fname = fname == "/" and M.indexFile or fname:sub(2, -1)

        ftype = select(3, fname:find("%.([%a%d]+)$"))
        ftype = ftype and ftype:lower()

        if M.callbacks[fname] then
            M.callbacks[fname](conn, fname, ftype, reqParam)
        elseif file.open(fname, "r") then
            M.sendResponseHeader(conn, "200 OK", M.extmap[ftype] or M.defaultContentType)
            sendFileContents(conn)
            file.close()
        else
            M.sendResponseHeader(conn, "404 Not Found","text/plain")
            conn:send("Page not found")
        end
        fname, ftype, reqParam = nil, nil, nil
    else
        M.sendResponseHeader(conn, "400 Bad Request","text/plain")
        conn:send("Invaild Request")
    end

    _, method, req, request = nil, nil, nil, nil
end

function M.stop()
    if M.server then
        M.server:close()
        M.server = nil
    end
end

function M.start()
    M.stop()
    
    M.server = net.createServer(net.TCP)
    M.server:listen(80, function(conn)
        conn:on("receive", onReceive)
        conn:on("sent", function(conn)
            conn:close()
            conn = nil
        end)
    end)
end


return M
