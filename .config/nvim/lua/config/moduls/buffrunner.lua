local current_file = debug.getinfo(1, "S").source:sub(2)
local current_dir  = vim.fn.fnamemodify(current_file, ":h")

local function get_buffer_info()
	return {
		full_path = vim.fn.expand("%:p"),
		dir_path  = vim.fn.expand("%:p:h"),
		path_out  = vim.fn.expand("%:r"),
		file_eks  = vim.fn.expand("%:e"),
		base_name = vim.fn.expand("%:t:r"),
	}
end

local function config(ext, info)
	local cfg = {
		html = {
			run = string.format("%s/server %s", current_dir, info.full_path),
			addr = "127.0.0.1:3000"
		},

		py = {
			run = "python3 " .. info.full_path,
		},

		sh = {
			run = "/data/data/com.termux/files/usr/bin/bash " .. info.full_path,
		},

		lua = {
			run = "lua " .. info.full_path,
		},

		fish = {
			run = "fish " .. info.full_path,
		},

		rs = {
			run = 'cd %:h && RUSTFLAGS\\=\\"-Awarnings\\" cargo run -q',
		},

		cpp = {
			compile = string.format("g++ %s -o %s", info.full_path, info.path_out),
			run     = string.format("&& %s", info.path_out),
			delTemp = string.format("&& rm -f %s", info.path_out),
		},

		java = {
			compile = string.format("javac %s -d %s", info.full_path, info.path_out),
			run     = string.format("&& cd %s && java %s", info.path_out, info.base_name),
			delTemp = string.format("&& rm -rf %s", info.path_out),
		},

		kt = {
			compile = string.format("kotlinc %s -include-runtime -d %s.jar", info.full_path, info.path_out),
			run     = string.format("&& java -jar %s.jar", info.path_out),
			delTemp = string.format("&& rm -f %s.jar", info.path_out .. ".jar"),
		},
	}

	return cfg[ext]
end

local function setup()
	local info = get_buffer_info()
	local conf = config(info.file_eks, info)

	if not conf then
		vim.notify(
			"\n[Err] File type belum di-setup!\nSupport: sh, fish, cpp, rs, java, kt\n",
			vim.log.levels.ERROR
		)
		return
	end

	-- gabungkan compile > run > delTemp
	local cmd = table.concat(vim.tbl_filter(function(v) return v end, {
		conf.compile,
		conf.run,
		conf.delTemp,
		conf.addr,
	}), " ")

	if cmd ~= "" then
		vim.cmd.w()
		vim.cmd("split term://" .. cmd)
	end

	-- HTML auto-open
	if info.file_eks == "html" then
		vim.defer_fn(function()
			local url = string.format("http://%s/%s.html", conf.addr, info.base_name)
			vim.fn.system("xdg-open " .. url)
		end, 100)
	end
end


-- Setup keymap
-- vim.keymap.set("n", "<leader>rr", function()
-- 	require("moduls.coder").run()
-- end, { noremap = true, silent = true })


return {
	buffrunner = setup,
}
