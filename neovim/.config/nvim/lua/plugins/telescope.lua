return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- Telescope is a fuzzy finder that comes with a lot of different things that
			-- it can fuzzy find! It's more than just a "file finder", it can search
			-- many different aspects of Neovim, your workspace, LSP, and more!
			--
			-- The easiest way to use Telescope, is to start by doing something like:
			--  :Telescope help_tags
			--
			-- After running this command, a window will open up and you're able to
			-- type in the prompt window. You'll see a list of `help_tags` options and
			-- a corresponding preview of the help.
			--
			-- Two important keymaps to use while in Telescope are:
			--  - Insert mode: <c-/>
			--  - Normal mode: ?
			--
			-- This opens a window that shows you all of the keymaps for the current
			-- Telescope picker. This is really useful to discover what Telescope can
			-- do as well as how to actually do it!

			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`

            -- import telescope actions safely
            local actions_setup, actions = pcall(require, "telescope.actions")
            if not actions_setup then
                return
            end

			require("telescope").setup({
				-- You can put your default mappings / updates / etc. in here
				--  All the info you're looking for is in `:help telescope.setup()`
				--
                -- configure custom mappings
                defaults = {
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                            ["<C-j>"] = actions.move_selection_next, -- move to next result
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
                        },
                    },
                },
				pickers = {
                    find_files = {
                        theme = "ivy"
                    }
                },
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind by [G]rep' })
			vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind current [W]ord' })
			vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
			vim.keymap.set('n', '<leader>ft', builtin.treesitter, { desc = '[F]ind [T]reesitter' })
			vim.keymap.set('n', '<leader>fcb', builtin.current_buffer_fuzzy_find, { desc = '[F]ind in [C]urrent [B]uffer' })
			vim.keymap.set('n', '<leader>fa', builtin.tags, { desc = '[F]ind T[A]gs' })
			vim.keymap.set('n', '<leader>fca', builtin.current_buffer_tags, { desc = '[F]ind [C]urrent Buffer T[A]gs' })
			vim.keymap.set('n', '<leader>if', builtin.git_files, { desc = 'G[I]t [F]iles' })
			vim.keymap.set('n', '<leader>ic', builtin.git_commits, { desc = 'G[I]t [C]ommits' })
			vim.keymap.set('n', '<leader>ib', builtin.git_bcommits, { desc = 'G[I]t [B]uffer Commits' })
			vim.keymap.set('n', '<leader>in', builtin.git_branches, { desc = 'G[I]t Bra[N]ches' })
			vim.keymap.set('n', '<leader>is', builtin.git_status, { desc = 'G[I]t [S]tatus' })
			vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [R]esume' })
			vim.keymap.set('n', '<leader>fx', builtin.commands, { desc = '[F]ind Commands to E[X]ecute' })
			vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = '[F]ind [Q]uickfix' })
			vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = '[F]ind [O]ld Files' })
			vim.keymap.set('n', '<leader>sh', builtin.search_history, { desc = '[S]earch [H]istory' })
			vim.keymap.set('n', '<leader>fv', builtin.vim_options, { desc = '[F]ind [V]im Options' })
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })
			vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind [B]uffers' })
			vim.keymap.set('n', '<leader>rp', builtin.registers, { desc = '[R]egister [P]aste (<C-e> to edit)' })
			vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' })
			vim.keymap.set('n', '<leader>fit', builtin.builtin, { desc = '[F]ind [I]n Telescope' })
			vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
			vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })

            -- Search man pages
			vim.keymap.set('n', '<leader>fm', function()
                builtin.man_pages({sections = {"ALL"}})
            end, { desc = '[F]ind [M]an Pages' })

			-- Explore colorschemes 
            vim.keymap.set('n', '<leader>cs', function()
                builtin.colorscheme({enable_preview=true})
            end, { desc = '[C]olor [S]cheme' })

			-- Slightly advanced example of overriding default behavior and theme
			vim.keymap.set("n", "<leader>/", function()
				-- You can pass additional configuration to Telescope to change the theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			-- It's also possible to pass additional configuration options.
			--  See `:help telescope.builtin.live_grep()` for information about particular keys
			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			-- Shortcut for searching your Neovim configuration files
			vim.keymap.set("n", "<leader>sn", function()
                local opts = require('telescope.themes').get_ivy({
                    cwd = vim.fn.stdpath("config")
                })
				builtin.find_files(opts)
			end, { desc = "[S]earch [N]eovim files" })
		end,
	}
}

