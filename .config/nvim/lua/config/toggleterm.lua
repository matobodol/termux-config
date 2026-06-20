local M = {}

--------------------------------------------------
-- state
--------------------------------------------------
M.direction = "float"

--------------------------------------------------
-- open / toggle
--------------------------------------------------
function M.toggle()
	vim.cmd("ToggleTerm direction=" .. M.direction)
end

--------------------------------------------------
-- set direction
--------------------------------------------------
function M.horizontal()
	M.direction = "horizontal"

	if vim.bo.buftype == "terminal" then
		vim.cmd("ToggleTerm")
		vim.cmd("ToggleTerm direction=horizontal")
	end
end

function M.vertical()
	M.direction = "vertical"

	if vim.bo.buftype == "terminal" then
		vim.cmd("ToggleTerm")
		vim.cmd("ToggleTerm direction=vertical")
	end
end

function M.float()
	M.direction = "float"

	if vim.bo.buftype == "terminal" then
		vim.cmd("ToggleTerm")
		vim.cmd("ToggleTerm direction=float")
	end
end

return M
