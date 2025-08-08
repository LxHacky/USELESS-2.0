local print_ascii_art = require("ascii_chars")
local colors = require("ansi_colors")
local set_color = colors.set_color
local json = require("dkjson")

local function read_content(path)
    local file = io.read()
    local content = file:read()
    local table, _, err = json.decode(content, 1, nil)
    if err then
        error("Err parsing JSON: " .. err)
    end
    return table
end

local ppt_content = read_content("useless.json")
