local go = require 'go.impl'
-- Map Normal Command
local mapic = function(keys, cmd, desc)
  vim.keymap.set('n', '<leader><leader>' .. keys, cmd, {
    buffer = true,
    desc = 'FT: ' .. desc,
  })
end

mapic('c', ':GoCmt<CR>', 'Go comment method')
mapic('\\', ':GoPkgOutline<CR>', 'Go Pkg Outline')

mapic('ta', ':GoAddTag ', 'Go Add Tag')
mapic('tr', ':GoRmTag ', 'Go Rm Tag')
mapic('tc', ':GoClearTag<CR>', 'Go Clear Tag')

mapic('fe', ':GoIfErr<CR>', 'Go Add If Error')
mapic('fs', ':GoFillStruct<CR>', 'Go Fill Struct')
mapic('fc', ':GoFillSwitch<CR>', 'Go Fill Switch')

mapic('p', ':GoFixPlurals<CR>', 'Go Fix Plurial')

mapic('l', ':GoLint<CR>', 'Go Lint')

mapic('i', ':GoImpl', 'Go implement')
mapic('i', function()
  local telescope = require 'telescope.builtin'
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local goImpl = require 'go.impl'
  -- Get all interfaces in the current project
  local results = goImpl.get_interfaces()

  pickers
    .new({}, {
      prompt_title = 'Go Interfaces',
      finder = finders.new_table {
        results = results,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry,
            ordinal = entry,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            goImpl.run(selection.value)
          end
        end)
        return true
      end,
    })
    :find()
end, 'Go implement')
