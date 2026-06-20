local M = {}

local Terminal = require("toggleterm.terminal").Terminal

--------------------------------------------------
-- Dedicated horizontal runner
--------------------------------------------------
local runner = Terminal:new({
	count = 99,
	direction = "horizontal",
	hidden = true,
	close_on_exit = false,
})

--------------------------------------------------
-- Resize terminal window
--------------------------------------------------
local function resize_runner()
	local size = math.floor(vim.o.lines * 0.55)

	vim.cmd("resize " .. size)
end

--------------------------------------------------
-- Build command
--------------------------------------------------
local function get_command()
	local file = vim.fn.expand("%:p")
	local ext  = vim.fn.expand("%:e")
	local dir  = vim.fn.expand("%:p:h")

	if file == "" then
		return nil, "File belum disimpan"
	end

	local commands = {
		rs   = string.format(
			'cd %s && RUSTFLAGS="-Awarnings" cargo run -q',
			dir
		),

		py   = "python3 " .. file,
		lua  = "lua " .. file,
		sh   = "bash " .. file,
		fish = "fish " .. file,
	}

	if not commands[ext] then
		return nil, "Ext tidak didukung: " .. ext
	end

	return commands[ext]
end

--------------------------------------------------
-- Run current buffer
--------------------------------------------------
function M.run()
	local cmd, err = get_command()

	if not cmd then
		vim.notify(err, vim.log.levels.WARN)
		return
	end

	vim.cmd("write")

	runner.cmd = cmd
	runner:open()

	vim.defer_fn(function()
		resize_runner()
	end, 30)
end

--------------------------------------------------
-- Stop current process
--------------------------------------------------
function M.stop()
	if runner:is_open() then
		runner:send("\003", false)
	end
end

--------------------------------------------------
-- Toggle runner
--------------------------------------------------
function M.toggle()
	runner:toggle()

	vim.defer_fn(function()
		if runner:is_open() then
			resize_runner()
		end
	end, 30)
end

return M
