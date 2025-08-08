local print_ascii_art = require("ascii_chars")
local json = require("dkjson")
local set_color = require("ansi_colors")

local delay = 0.1

local function draw_line(char)
    local width = tonumber(os.getenv("COLUMNS")) or 80
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

local function typewriter_print(message)
    for i = 1, #message do
        io.write(message:sub(i, i))
        io.flush()
        os.execute("sleep " .. delay)
    end
    print()
end

local function delayed_call(callback, args, _delay)
    os.execute("sleep " .. tonumber(_delay))
    callback(table.unpack(args))
end

local content = read_json("./useless.json")
if not content then
  error("could not open file ")
end

local function handle_effects(effect, message)
    if effect == "delay" then
        delayed_call(print, {message}, 1)
    elseif effect == "typewriter" then
        typewriter_print(message)
    end
end

local function process_paragraph(paragraph)
    if paragraph.attributes then
        local attributes = paragraph.attributes
        if attributes.color then set_color(attributes.color) end
        if attributes.delay then os.execute("sleep " .. tonumber(attributes.delay)) end
        if attributes.effect then handle_effects(attributes.effect, paragraph.text) end
    end
    if not paragraph.attributes.effect then print(paragraph.text) end
    set_color("reset")
end

local function process_ascii(ascii)
    if ascii.attributes then
        local attributes = ascii.attributes
        if attributes.color then set_color(attributes.color) end
        if attributes.delay then os.execute("sleep " .. tonumber(attributes.delay)) end
    end
    print_ascii_art(ascii.text)
    set_color("reset")
end

for _, slide in ipairs(content) do
    for _, entity in ipairs(slide) do
        if entity == "line" then
            draw_line("#")
        elseif entity == "newline" then
            print()
        elseif entity.paragraph then
            process_paragraph(entity.paragraph)
        elseif entity.ascii then
            process_ascii(entity.ascii)
        end
    end
end

