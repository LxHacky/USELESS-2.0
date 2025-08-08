local print_ascii_art = require("ascii_chars")
local colors = require("ansi_colors")
local set_color = colors.set_color


local myname = io.read()
print_ascii_art(myname)
