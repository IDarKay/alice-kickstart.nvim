local curl = require 'plenary.curl'

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local M = {
  github_base_api_url = 'https://api.github.com/repos',
  github_headers = {
    Accept = 'application/vnd.github+json',
    ['X-GitHub-Api-Version'] = '2022-11-28',
  },
  k8s = {
    schemas_catalog = 'yannh/kubernetes-json-schema',
    schema_catalog_branch = 'master',
    is_init = false,
    trees = {},
    target_version = 'master-local',
  },
  crd = {
    schemas_catalog = 'datreeio/CRDs-catalog',
    schema_catalog_branch = 'main',
    is_init = false,
    trees = {},
  },
}

M.k8s.schema_url = 'https://raw.githubusercontent.com/' .. M.k8s.schemas_catalog .. '/' .. M.k8s.schema_catalog_branch .. '/' .. M.k8s.target_version
M.crd.schema_url = 'https://raw.githubusercontent.com/' .. M.crd.schemas_catalog .. '/' .. M.crd.schema_catalog_branch

local function insert_after_yaml_separator(text)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local insert_line = 0

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  for i = cursor_line - 1, 1, -1 do
    if lines[i]:match '^%-%-%-$' then
      insert_line = i
      break
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, insert_line, insert_line, false, { text })
end

M.get_trees_json_filtered = function(url)
  local response = curl.get(url, { headers = M.github_headers, query = { recursive = 1 } })
  local body = vim.fn.json_decode(response.body)
  local trees = {}
  for _, tree in ipairs(body.tree) do
    if tree.type == 'blob' and tree.path:match '%.json$' then
      table.insert(trees, tree.path)
    end
  end
  return trees
end

M.crd.list_github_tree = function()
  if not M.crd.is_init then
    local url = M.github_base_api_url .. '/' .. M.crd.schemas_catalog .. '/git/trees/' .. M.crd.schema_catalog_branch
    M.crd.trees = M.get_trees_json_filtered(url)
    M.crd.is_init = true
  end
  return M.crd.trees
end

M.k8s.list_github_tree = function()
  if not M.k8s.is_init then
    local url = M.github_base_api_url .. '/' .. M.k8s.schemas_catalog .. '/git/trees/' .. M.k8s.schema_catalog_branch
    local response = curl.get(url, { headers = M.github_headers })
    local body = vim.fn.json_decode(response.body)

    for _, tree in ipairs(body.tree) do
      if tree.type == 'tree' and tree.path == M.k8s.target_version then
        M.k8s.trees = M.get_trees_json_filtered(tree.url)
        M.k8s.is_init = true
        break
      end
    end
  end
  return M.k8s.trees
end

M.run = function(repo)
  local all_crds = repo.list_github_tree()
  if #all_crds == 0 then
    vim.notify('No schemas found.', vim.log.levels.WARN)
    return
  end
  vim.ui.select(all_crds, { prompt = 'Select schema: ' }, function(selection)
    if not selection then
      vim.notify('Canceled.', vim.log.levels.WARN)
      return
    end
    local schema_url = repo.schema_url .. '/' .. selection
    local schema_modeline = '# yaml-language-server: $schema=' .. schema_url
    -- vim.api.nvim_buf_set_lines(0, 0, 0, false, { schema_modeline })
    insert_after_yaml_separator(schema_modeline)
    vim.notify('Added schema modeline: ' .. schema_modeline)
  end)
end

M.run_telescope = function(repo)
  local all_crds = repo.list_github_tree()
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

          local schema_url = repo.schema_url .. '/' .. selection[1]
          local schema_modeline = '# yaml-language-server: $schema=' .. schema_url
          -- vim.api.nvim_buf_set_lines(0, 0, 0, false, { schema_modeline })
          insert_after_yaml_separator(schema_modeline)
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

M.k8s.run_telescope = function()
  M.run_telescope(M.k8s)
end

M.crd.run_telescope = function()
  M.run_telescope(M.crd)
end
return M
