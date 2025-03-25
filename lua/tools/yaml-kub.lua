local curl = require 'plenary.curl'

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local M = {
  schemas_catalog = 'datreeio/CRDs-catalog',
  schema_catalog_branch = 'main',
  github_base_api_url = 'https://api.github.com/repos',
  github_headers = {
    Accept = 'application/vnd.github+json',
    ['X-GitHub-Api-Version'] = '2022-11-28',
  },
  trees = {},
  isInit = false,
}
M.schema_url = 'https://raw.githubusercontent.com/' .. M.schemas_catalog .. '/' .. M.schema_catalog_branch

M.list_github_tree = function()
  if not M.isInit then
    local url = M.github_base_api_url .. '/' .. M.schemas_catalog .. '/git/trees/' .. M.schema_catalog_branch
    local response = curl.get(url, { headers = M.github_headers, query = { recursive = 1 } })
    local body = vim.fn.json_decode(response.body)
    local trees = {}
    for _, tree in ipairs(body.tree) do
      if tree.type == 'blob' and tree.path:match '%.json$' then
        table.insert(trees, tree.path)
      end
    end
    M.trees = trees
    M.isInit = true
  end
  return M.trees
end

M.run = function()
  local all_crds = M.list_github_tree()
  vim.ui.select(all_crds, { prompt = 'Select schema: ' }, function(selection)
    if not selection then
      vim.notify('Canceled.', vim.log.levels.WARN, {})
      return
    end
    local schema_url = M.schema_url .. '/' .. selection
    local schema_modeline = '# yaml-language-server: $schema=' .. schema_url
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { schema_modeline })
    vim.notify('Added schema modeline: ' .. schema_modeline)
  end)
end

M.run_telescope = function()
  local all_crds = M.list_github_tree()
  if #all_crds == 0 then
    vim.notify('No schemas found.', vim.log.levels.WARN)
    return
  end

  pickers
    .new({}, {
      prompt_title = 'Select Schema',
      finder = finders.new_table {
        results = all_crds,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        local function on_select()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if not selection then
            vim.notify('Canceled.', vim.log.levels.WARN)
            return
          end

          local schema_url = M.schema_url .. '/' .. selection[1]
          local schema_modeline = '# yaml-language-server: $schema=' .. schema_url
          vim.api.nvim_buf_set_lines(0, 0, 0, false, { schema_modeline })
          vim.notify('Added schema modeline: ' .. schema_modeline)
        end

        map('i', '<CR>', function()
          on_select()
        end)
        map('n', '<CR>', function()
          on_select()
        end)

        return true
      end,
    })
    :find()
end

return M
