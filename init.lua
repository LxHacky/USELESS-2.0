local print_ascii_art = require("ascii_chars")
local json = require("dkjson")

local colors = require("ansi_colors")
local set_color = colors.set_color


local function draw_line(char)
    local width = tonumber(os.getenv("COLUMNS")) or 80 -- fallback to 80 if unknown
    local line = string.rep(char, width)
    print(line)
end


local function read_json(path)
    if not path then return end
    local file = io.open(path, "r")
    if not file then
        error("could not open " .. path)
    end
    local content = file:read("*a")
    file:close()

    local table, _, err = json.decode(content, 1, nil)
    if err then
        error("Err parsing JSON: " .. err)
    end
    return table
end

local content = read_json("./useless.json")
if not content then
  error("could not open file ")
end

draw_line("#")
