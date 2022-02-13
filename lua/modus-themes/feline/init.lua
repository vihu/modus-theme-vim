local M = {}

function M.set_statusline(colors)
	local lsp = require("feline.providers.lsp")
	local vi_mode_utils = require("feline.providers.vi_mode")

	local vi_mode_colors = {
		NORMAL = colors.green_active[1],
		INSERT = colors.red_active[1],
		VISUAL = colors.magenta_active[1],
		OP = colors.green_active[1],
		BLOCK = colors.blue_active[1],
		REPLACE = colors.magenta_alt[1],
		["V-REPLACE"] = colors.magenta_alt[1],
		ENTER = colors.cyan_active[1],
		MORE = colors.cyan_active[1],
		SELECT = colors.red_alt[1],
		COMMAND = colors.green_active[1],
		SHELL = colors.green_active[1],
		TERM = colors.green_active[1],
		NONE = colors.yellow_active[1],
	}

	local icons = {
		linux = " ",
		macos = " ",
		windows = " ",

		errs = " ",
		warns = " ",
		infos = " ",
		hints = " ",

		lsp = " ",
		git = "",
	}

	local function file_osinfo()
		local os = vim.bo.fileformat:upper()
		local icon
		if os == "UNIX" then
			icon = icons.linux
		elseif os == "MAC" then
			icon = icons.macos
		else
			icon = icons.windows
		end
		return icon .. os
	end

	local function lsp_diagnostics_info()
		return {
			errs = lsp.get_diagnostics_count("Error"),
			warns = lsp.get_diagnostics_count("Warning"),
			infos = lsp.get_diagnostics_count("Information"),
			hints = lsp.get_diagnostics_count("Hint"),
		}
	end

	local function diag_enable(f, s)
		return function()
			local diag = f()[s]
			return diag and diag ~= 0
		end
	end

	local function diag_of(f, s)
		local icon = icons[s]
		return function()
			local diag = f()[s]
			return icon .. diag
		end
	end

	local function vimode_hl()
		return {
			name = vi_mode_utils.get_mode_highlight_name(),
			fg = vi_mode_utils.get_mode_color(),
		}
	end

	-- LuaFormatter off

	local comps = {
		vi_mode = {
			left = {
				provider = "▊",
				hl = vimode_hl,
				right_sep = " ",
			},
			right = {
				provider = "▊",
				hl = vimode_hl,
				left_sep = " ",
			},
		},
		file = {
			info = {
				provider = "file_info",
				hl = {
					fg = colors.blue_active[1],
					style = "bold",
				},
			},
			encoding = {
				provider = "file_encoding",
				left_sep = " ",
				hl = {
					fg = colors.magenta_active[1],
					style = "bold",
				},
			},
			type = {
				provider = "file_type",
			},
			os = {
				provider = file_osinfo,
				left_sep = " ",
				hl = {
					fg = colors.magenta_active[1],
					style = "bold",
				},
			},
		},
		line_percentage = {
			provider = "line_percentage",
			left_sep = " ",
			hl = {
				style = "bold",
			},
		},
		scroll_bar = {
			provider = "scroll_bar",
			left_sep = " ",
			hl = {
				fg = colors.blue_active[1],
				style = "bold",
			},
		},
		diagnos = {
			err = {
				provider = diag_of(lsp_diagnostics_info, "errs"),
				left_sep = " ",
				enabled = diag_enable(lsp_diagnostics_info, "errs"),
				hl = {
					fg = colors.red_active[1],
				},
			},
			warn = {
				provider = diag_of(lsp_diagnostics_info, "warns"),
				left_sep = " ",
				enabled = diag_enable(lsp_diagnostics_info, "warns"),
				hl = {
					fg = colors.yellow_active[1],
				},
			},
			info = {
				provider = diag_of(lsp_diagnostics_info, "infos"),
				left_sep = " ",
				enabled = diag_enable(lsp_diagnostics_info, "infos"),
				hl = {
					fg = colors.blue_active[1],
				},
			},
			hint = {
				provider = diag_of(lsp_diagnostics_info, "hints"),
				left_sep = " ",
				enabled = diag_enable(lsp_diagnostics_info, "hints"),
				hl = {
					fg = colors.cyan_active[1],
				},
			},
		},
		lsp = {
			name = {
				provider = "lsp_client_names",
				left_sep = " ",
				icon = icons.lsp,
				hl = {
					fg = colors.yellow_active[1],
				},
			},
		},
		git = {
			branch = {
				provider = "git_branch",
				icon = icons.git,
				left_sep = " ",
				hl = {
					fg = colors.magenta_active[1],
					style = "bold",
				},
			},
			add = {
				provider = "git_diff_added",
				hl = {
					fg = colors.green_active[1],
				},
			},
			change = {
				provider = "git_diff_changed",
				hl = {
					fg = colors.magenta_alt[1],
				},
			},
			remove = {
				provider = "git_diff_removed",
				hl = {
					fg = colors.red_active[1],
				},
			},
		},
	}

	local properties = {
		force_inactive = {
			filetypes = {
				"NvimTree",
				"dbui",
				"packer",
				"startify",
				"fugitive",
				"fugitiveblame",
			},
			buftypes = { "terminal" },
			bufnames = {},
		},
	}

	local components = {
		left = {
			active = {
				comps.vi_mode.left,
				comps.file.info,
				comps.lsp.name,
				comps.diagnos.err,
				comps.diagnos.warn,
				comps.diagnos.hint,
				comps.diagnos.info,
			},
			inactive = {
				comps.vi_mode.left,
				comps.file.info,
			},
		},
		mid = {
			active = {},
			inactive = {},
		},
		right = {
			active = {
				comps.git.add,
				comps.git.change,
				comps.git.remove,
				comps.file.os,
				comps.git.branch,
				comps.line_percentage,
				comps.scroll_bar,
				comps.vi_mode.right,
			},
			inactive = {},
		},
	}

	-- LuaFormatter on

	require("feline").setup({
		default_bg = colors.bg_active[1],
		default_fg = colors.fg_active[1],
		components = components,
		properties = properties,
		vi_mode_colors = vi_mode_colors,
	})
end

return M
