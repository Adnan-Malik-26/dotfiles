hl.window_rule({
	name = "firefox-pip-float",
	float = true,
	match = {
		class = "^firefox$",
		title = "^(Picture-in-Picture)",
	},
})

hl.window_rule({
	name = "otter-launcher",
	match = {
		class = "otter",
	},
	float = true,
	animation = "popin 80%",
	size = { 500, 300 },
	opaque = true,
})

-- Dont dim youtube windows
hl.window_rule({
	name = "nodim-youtube",
	match = {
		class = "^(firefox|Firefox|helium)$",
		title = "^(.*YouTube.*)$",
	},
	no_dim = true,
	opaque = true,
})

hl.layer_rule({
	match = {
		namespace = "swaync-control-center",
	},

	animation = "slide left",
})

hl.window_rule({
	name = "zen-pip-float",
	float = true,
	match = {
		class = "^(zen|firefox|Firefox|helium)$",
		title = "^(Picture-in-Picture)",
	},
})

hl.window_rule({
	name = "firefox-google-signin-float",
	float = true,
	match = {
		title = "^(Sign in – Google accounts — Mozilla Firefox)",
	},
})

hl.window_rule({
	name = "kairu-tile",
	tile = true,
	match = {
		class = "^(Chromium)$",
		title = "^(Kairu - Track your time like it matters)$",
	},
})

hl.window_rule({
	name = "thunar-opacity",
	opacity = "0.9 0.9",
	match = {
		class = "^(Thunar)$",
	},
})

hl.window_rule({
	name = "thorium-tile",
	tile = true,
	match = {
		class = "^(Thorium-browser)",
	},
})

hl.window_rule({
	name = "launcher-float",
	float = true,
	match = {
		class = "^(launcher)$",
	},
})

hl.window_rule({
	name = "launcher-size-center",
	size = "800 500",
	center = true,
	match = {
		class = "^(launcher)$",
	},
})
