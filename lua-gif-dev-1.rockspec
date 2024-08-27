package = "lua-gif"
version = "dev-1"
source = {
	url = "git+ssh://git@github.com/jules-timmerman/lua-gif.git",
}
description = {
	summary = "This simple module uses Tenor API to search GIFs in Lua",
	detailed = [[
This simple module uses Tenor API to search GIFs in Lua
]],
	homepage = "https://github.com/jules-timmerman/lua-gif",
	license = "MIT",
}
dependencies = {
	"lua >= 5.1",
	"luasec",
	"lua-cjson",
}
build = {
	type = "builtin",
	modules = {
		gif = "gif.lua",
	},
	copy_directories = {
		"doc",
	},
}
