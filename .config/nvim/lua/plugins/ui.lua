return {
	{
		"sphamba/smear-cursor.nvim",

		opts = {
			-- Smear cursor when switching buffers or windows.
			smear_between_buffers = true,

			-- Smear cursor when moving within line or to neighbor lines.
			-- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
			smear_between_neighbor_lines = true,

			-- Draw the smear in buffer space instead of screen space when scrolling
			scroll_buffer_space = true,

			-- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
			-- Smears and particles will look a lot less blocky.
			legacy_computing_symbols_support = false,

			-- Smear cursor in insert mode.
			-- See also `vertical_bar_cursor_insert_mode` and `distance_stop_animating_vertical_bar`.
			smear_insert_mode = true,
		},
	},

	{
		"Mofiqul/dracula.nvim",

		lazy = false,
		name = "dracula",
		config = function()
			require("config.dracula")
			vim.cmd("colorscheme dracula")
		end,
	},
	-- ========== COLORSCHEME (Load pertama) ==========
	{
		"folke/tokyonight.nvim",
		lazy = false, -- Load segera untuk menghindari flash
		priority = 1000,
		config = function()
			-- vim.cmd([[colorscheme tokyonight]])
		end,
	},

	-- ========== STATUSLINE ==========
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy", -- Load setelah UI lain siap
		config = function()
			require("config.lualine")
		end
	},

	-- Mini.nvim (horizontal scope)
	{
		"echasnovski/mini.nvim",
		version = false,
		event = "VeryLazy",
		config = function()
			require('mini.indentscope').setup()
		end
	},

	-- ========== INDENT GUIDES ==========
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		main = "ibl",
		config = function()
			require("config.ibl")
		end
	},

	-- ========== WHICH-KEY ==========
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup()
		end,
	},

	-- ========== NOTIFICATIONS ==========
	{
		"rcarriga/nvim-notify",
		-- event = "VeryLazy",
		lazy = false,
		keys = { -- Keymap langsung di plugin spec
			{ "<leader>nc", function() require("notify").clear_history() end, desc = "Clear notifications" },
			-- { "<leader>nn", function() require("notify").history() end,       desc = "Show notification history" },
		},
		config = function()
			-- di plugins/init.lua
			require("notify").setup({
				-- Pengaturan ukuran
				max_width = function() return math.floor(vim.o.columns * 0.5) end,
				max_height = function() return math.floor(vim.o.lines * 0.5) end,

				timeout = 3000,
				-- Atau nilai tetap
				-- max_width = 80,
				-- max_height = 20,
				-- Enable history
				history = true, -- Simpan history
				render = "default",
				stages = "fade_in_slide_out",

				-- Posisi history window
				background_colour = "#1a1b26",
				fps = 30,
			})

			vim.notify = require("notify")
		end,
	},
}
