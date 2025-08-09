#! /usr/bin/env lua
local print_ascii_art = require("./libs/ascii_chars")
local set_color = require("./libs/ansi_colors")
local json = require("dkjson")

local delay = 0.1
local width = 80
local line_char = "#"

local function draw_line(char)
    set_color("grey")
    local line = string.rep(char, width)
    print(line)
    set_color("reset")
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

local function handle_effects(effect, message)
    if effect == "typewriter" then
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
    print_ascii_art(ascii.text);
    set_color("reset")
end

local root = read_json(arg[1])
if not root then
  error("could not open file ")
end

if root.width then width = root.width end
if root.line_character then line_char = root.line_character end

os.execute("clear")
if root.body then
    for i, slide in ipairs(root.body) do
        set_color("grey")
        print("\n[[ " .. i .. " ]]")
        set_color("reset")
        for _, entity in ipairs(slide) do
            if entity == "line" then
                draw_line(line_char)
            elseif entity == "newline" then
                print()
            elseif entity == "refresh" then
                os.execute("clear")
            elseif entity.paragraph then
                process_paragraph(entity.paragraph)
            elseif entity.ascii then
                process_ascii(entity.ascii)
            end
        end
        io.write("\npress Enter to continue..");
        io.read()
    end
end

set_color("red")
print("\n[[ END ]]\n")
set_color("reset")
