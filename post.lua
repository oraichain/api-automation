-- HTTP POST script which simulates a file upload
-- HTTP method, body, and adding a header

local argparse = require "argparse"
local puremagic = require('puremagic')


local parser = argparse("script", "An example.")
parser:option("-f --file", "Image file."):count("*")
parser:option("-d --data", "Form data.", "request_id=12121212&card_type=identify&customer_id=12121212&app_id=asdasdasdasd")

local charset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

function randomString(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.clock()^5)
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

local Boundary = "----WebKitFormBoundary" .. randomString(16)
local BodyBoundary = "--" .. Boundary
local LastBoundary = "--" .. Boundary .. "--"
local CRLF = "\r\n"
local filenames
local form_data_body = ""
local counter = 1

function read_txt_file(path)
    local file, errorMessage = io.open(path, "r")    
    if not file then 
        error("Could not read the file:" .. errorMessage .. "\n")
    end

    local content = file:read "*all"
    file:close()
    return content
end


function get_form_data(field, filename, isFile)
    local content = BodyBoundary .. CRLF .. "Content-Disposition: form-data; name=\"" .. field .. "\""
    if isFile then
        local file_content = read_txt_file(filename)
        local mimetype = puremagic.via_content(file_content, filename)
        content = content .. "; filename=\"" .. filename .. "\"" 
        content = content .. CRLF .. "Content-Type: " .. mimetype        
        content = content .. CRLF .. CRLF .. file_content
    else 
        content = content .. CRLF .. CRLF .. filename
    end 
    content = content .. CRLF
    return content 
end     


-- special functions here

function init(args)     
    local data = parser:parse(args)    
    local form_data = {} 
    filenames = data['file']         
    for k, v in string.gmatch(data['data'], "([%w_]+)=([^&]*)") do
        form_data[k] = v
    end

    wrk.method = "POST"    
    wrk.headers["Content-Type"] = "multipart/form-data; boundary=" .. Boundary

    for field, value in pairs(form_data) do
        form_data_body = form_data_body .. get_form_data(field, value, false) 
    end     
    -- last boundary -- 
    form_data_body = form_data_body .. LastBoundary

end 

function request()    
    -- round robin file 
    local index = (counter - 1) % (table.getn(filenames)) + 1    
    local filename = filenames[index]
    -- print(index,filename)    
    
    wrk.body = get_form_data("file", filename, true) .. form_data_body    
        
    -- return request
    return wrk.format()
    
end

function response(status, headers, body)
    print(counter, body)
    counter = counter + 1
end
