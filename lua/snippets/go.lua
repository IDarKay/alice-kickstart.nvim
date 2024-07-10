local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets('go', {
  s('swagdoc', {
    t {
      '// @Summary ',
      '// @Description ',
      '// @Tags    ',
      '// @Produce json',
      '// @Param   ',
      '// @Success ',
      '// @Failure 401',
      '// @Failure 403',
      '// @Failure 404',
      '// @Failure 500',
      '// @Router',
    },
    i(0),
  }),
})
