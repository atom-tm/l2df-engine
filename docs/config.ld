project = 'L2DF'
title = 'L2DF Documentation'
description = 'Love2D Fighting'
full_description = '2D engine for fighting games. Read the @{01-introduction.md|manual} before you start.'
readme = { '../README.md', 'guide' }
file = '../src'
dir = '../docs'
format = 'discount'
style = true
template = true
not_luadoc = true
-- sort_modules = true
no_space_before_args = true
use_markdown_titles = true
kind_names = {topic = 'Manual', module = 'Modules'}

custom_tags = { 'deprecated', hidden = true }
custom_display_name_handler = function (item, default_handler)
  if item.type == 'function' and item.tags.deprecated then
    return string.format('[deprecated] %s', default_handler(item))
  end
  return default_handler(item)
end

alias('param', {'param', modifiers = {type = "$1"}})
alias('return', {'return', modifiers = {type = "$1"}})