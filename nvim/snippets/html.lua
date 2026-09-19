local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("!", {
		t({ "<!DOCTYPE html>", '<html lang="' }),
		i(1, "en"),
		t({ '">', "<head>", '    <meta charset="' }),
		i(2, "UTF-8"),
		t({ '">', '    <meta name="viewport" content="width=device-width, initial-scale=1.0">', "    <title>" }),
		i(3, "Document"),
		t({ "</title>", "</head>", "<body>", "    " }),
		i(0),
		t({ "", "</body>", "</html>" }),
	}),
}
