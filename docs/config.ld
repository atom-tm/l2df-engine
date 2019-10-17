project = 'L2DF'
title = 'L2DF documentation'
description = 'Love2D Fighting'
full_description = '2D engine for fighting games'
readme = {'../README.md'}
file = '../src'
dir = '../docs'
format = 'discount'
style = true
template = true
not_luadoc = true
no_space_before_args = true
use_markdown_titles = true
kind_names = {topic = 'Manual', module = 'Reference'}

alias('param', {'param', modifiers = {type = "$1"}})
alias('return', {'return', modifiers = {type = "$1"}})