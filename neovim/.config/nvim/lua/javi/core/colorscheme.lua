-- set colorscheme to nightfly with protected call
-- in case it isn't installed

-- local colorscheme = "colorscheme nightfly"
-- --local colorscheme = "colorscheme rose-pine"
-- local status, _ = pcall(vim.cmd, colorscheme)
-- if not status then
--   print("Colorscheme not found!") -- print error if colorscheme not installed
--   return
-- end

require("rose-pine").setup({
	disable_background = true,
})

function ColorMyPencils(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)
end

ColorMyPencils()
