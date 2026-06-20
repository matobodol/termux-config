return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async"
		},
		config = function()
			require("config.nvimufo")
		end,
	},
	-- ========== ESSENTIALS (Non-lazy) ==========
	{
		"nvim-lua/plenary.nvim",
		lazy = false, -- Dibutuhkan oleh banyak plugin
		priority = 1000, -- High priority
	},

	{
		"nvim-lua/popup.nvim",
		lazy = false,
		priority = 1000,
	},

	-- ========== EDITOR ENHANCEMENTS ==========
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter", -- Lazy load saat insert mode
		config = true,
	},

	{
		"numToStr/Comment.nvim",
		keys = { -- Lazy load saat keys ditekan
			{ "gc", mode = { "n", "v" } },
			{ "gb", mode = { "n", "v" } },
		},
		config = true,
	},

	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy", -- Load sangat telat
		config = true,
	},

	-- ========== BUFFER & WINDOW MANAGEMENT ==========
	{
		"akinsho/bufferline.nvim",
		event = "BufReadPre", -- Load saat buffer dibaca
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("config.bufferline")
		end,
	},

	{
		"nvim-tree/nvim-tree.lua",
		cmd = { "NvimTreeToggle", "NvimTreeFocus" }, -- Load saat command dipanggil
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<cr>" },
		},
		config = function()
			require("config.nvimtree")
		end,
	},
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = true,
	},
	{
		"utilyre/barbecue.nvim",
		event = "InsertEnter",
		name = "barbecue",
		version = "*",

		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		config = function()
			require("config.barbecue")
		end,
	},
}
