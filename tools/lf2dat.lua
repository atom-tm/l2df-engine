#!/usr/bin/env luajit
-- LF2 DAT converter for original Little Fighter 2 data files.
--
-- The converted output is unencrypted L2DF/LFFS2-style text compatible with
-- presets/lf2/data/template.dat. See docs/guide/11-lf2-dat-reference.md for
-- additional LF2 DAT format details when a field or frame element needs more
-- context.

local M = { }

M.KEY = 'odBearBecauseHeIsVeryGoodSiuHungIsAGo'
M.HEADER_SIZE = 123

local LF = '\n'
local path_sep = package.config:sub(1, 1)

local block_map = {
	bdy = { open = '<body>', close = '</body>' },
	body = { open = '<body>', close = '</body>' },
	itr = { open = '<itr>', close = '</itr>' },
	wpoint = { open = '[wpoint]', close = '[/wpoint]' },
	cpoint = { open = '[cpoint]', close = '[/cpoint]' },
	bpoint = { open = '[bpoint]', close = '[/bpoint]' },
	opoint = { open = '[opoint]', close = '[/opoint]' },
}

local gravity_types = {
	['0'] = true,
	['1'] = true,
	['2'] = true,
	['4'] = true,
	['5'] = true,
	['6'] = true,
}

local shadow_types = {
	['0'] = true,
	['1'] = true,
	['2'] = true,
	['3'] = true,
	['4'] = true,
	['5'] = true,
	['6'] = true,
}

local compatibility_sounds = {
	{ 'punch', 'data/sounds/001.wav' },
	{ 'block', 'data/sounds/002.wav' },
	{ 'super_punch', 'data/sounds/006.wav' },
	{ 'drop', 'data/sounds/016.wav' },
	{ 'bounce', 'data/sounds/016.wav' },
}

local function trim(str)
	return (str:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function normalize_path(str)
	return (str:gsub('\\', '/'))
end

local function denormalize_path(str)
	if path_sep == '/' then
		return normalize_path(str)
	end
	return (normalize_path(str):gsub('/', path_sep))
end

local function dirname(path)
	local normalized = path:gsub('\\', '/')
	local dir = normalized:match('^(.*)/[^/]+$')
	if not dir or dir == '' then
		return '.'
	end
	return dir
end

local function basename(path)
	return (path:gsub('\\', '/'):match('([^/]+)$') or path)
end

local function lower_ext(path)
	return normalize_path(path):lower():match('%.([%w]+)$')
end

local function replace_ext(path, ext)
	local normalized = normalize_path(path)
	return (normalized:gsub('%.[^./]+$', ext))
end

local function join_path(a, b)
	if not a or a == '' then
		return b
	end
	if a:sub(-1) == '/' or a:sub(-1) == '\\' then
		return a .. b
	end
	return a .. path_sep .. b
end

local function join_relative(root, relative)
	return join_path(root, denormalize_path(relative))
end

local function file_exists(path)
	local file = io.open(path, 'rb')
	if file then
		file:close()
		return true
	end
	return false
end

local function read_file(path, mode)
	local file, err = io.open(path, mode or 'rb')
	if not file then
		return nil, err
	end
	local data = file:read('*a')
	file:close()
	return data
end

local function write_file(path, data, mode)
	local file, err = io.open(path, mode or 'wb')
	if not file then
		return nil, err
	end
	file:write(data)
	file:close()
	return true
end

local function quote_command_path(path)
	return '"' .. tostring(path):gsub('"', '\\"') .. '"'
end

local function make_dir(dir)
	if path_sep == '\\' then
		os.execute(('if not exist %s mkdir %s'):format(quote_command_path(dir), quote_command_path(dir)))
	else
		os.execute(('mkdir -p %s'):format(quote_command_path(dir)))
	end
end

local function ensure_parent_dir(path)
	local dir = dirname(path)
	if dir and dir ~= '.' then
		make_dir(dir)
	end
end

local function copy_file(input_path, output_path)
	local data, err = read_file(input_path, 'rb')
	if not data then
		return nil, err
	end
	ensure_parent_dir(output_path)
	return write_file(output_path, data, 'wb')
end

local base64_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function base64_encode(data)
	local out = { }
	local len = #data
	for i = 1, len, 3 do
		local a = data:byte(i) or 0
		local b = data:byte(i + 1) or 0
		local c = data:byte(i + 2) or 0
		local n = a * 65536 + b * 256 + c
		out[#out + 1] = base64_chars:sub(math.floor(n / 262144) % 64 + 1, math.floor(n / 262144) % 64 + 1)
		out[#out + 1] = base64_chars:sub(math.floor(n / 4096) % 64 + 1, math.floor(n / 4096) % 64 + 1)
		out[#out + 1] = i + 1 <= len and base64_chars:sub(math.floor(n / 64) % 64 + 1, math.floor(n / 64) % 64 + 1) or '='
		out[#out + 1] = i + 2 <= len and base64_chars:sub(n % 64 + 1, n % 64 + 1) or '='
	end
	return table.concat(out)
end

local function utf16le_ascii(str)
	local out = { }
	for i = 1, #str do
		out[#out + 1] = str:sub(i, i)
		out[#out + 1] = '\0'
	end
	return table.concat(out)
end

local function ps_quote(value)
	return "'" .. tostring(value):gsub("'", "''") .. "'"
end

local function command_ok(result, why, code)
	return result == true or result == 0 or why == 'exit' and code == 0
end

local function split_lines(text)
	text = text:gsub('\r\n', '\n'):gsub('\r', '\n')
	if text:sub(-1) ~= '\n' then
		text = text .. '\n'
	end
	local lines = { }
	for line in text:gmatch('(.-)\n') do
		lines[#lines + 1] = line
	end
	return lines
end

local function parse_fields(line)
	local fields = { }
	local pos = 1
	while true do
		local key_start, key_end, key = line:find('([%w_]+)%s*:', pos)
		if not key_start then
			break
		end
		local next_start = line:find('[%w_]+%s*:', key_end + 1)
		local value_end = next_start and next_start - 1 or #line
		fields[#fields + 1] = {
			key = key,
			value = trim(line:sub(key_end + 1, value_end)),
		}
		pos = value_end + 1
	end
	return fields
end

local function format_value(value, key)
	if not value or value == '' then
		return ''
	end
	value = normalize_path(trim(value))
	if key == 'name' and value:find('%s') and not value:match('^".*"$') then
		return '"' .. value:gsub('"', '\\"') .. '"'
	end
	return value
end

local function format_field(key, value)
	if value == nil or value == '' then
		return key .. ':'
	end
	return key .. ': ' .. value
end

local function sound_target(sound_id)
	local file = basename(sound_id)
	return 'data/sounds/' .. normalize_path(file)
end

local function is_sprite_image(path)
	local ext = lower_ext(path)
	return ext == 'bmp' or ext == 'png'
end

local function wants_sprites(options)
	return options and (options.copy_sprites or options.copy_assets)
end

local function wants_sounds(options)
	return options and (options.copy_sounds or options.copy_assets)
end

local function converted_sprite_path(path, options)
	path = normalize_path(path)
	if wants_sprites(options) and is_sprite_image(path) then
		return replace_ext(path, '.png')
	end
	return path
end

local function add_sprite_asset(options, source, target)
	if not (wants_sprites(options) and source and target) then
		return
	end
	source = normalize_path(source)
	target = normalize_path(target)
	options.sprite_assets = options.sprite_assets or { }
	options.sprite_asset_set = options.sprite_asset_set or { }
	if not options.sprite_asset_set[source] then
		options.sprite_asset_set[source] = target
		options.sprite_assets[#options.sprite_assets + 1] = {
			source = source,
			target = target,
		}
	end
end

local function add_sound_asset(options, source)
	if not (wants_sounds(options) and source) then
		return
	end
	source = normalize_path(source)
	local target = sound_target(source)
	options.sound_assets = options.sound_assets or { }
	options.sound_asset_set = options.sound_asset_set or { }
	if not options.sound_asset_set[target] then
		options.sound_asset_set[target] = source
		options.sound_assets[#options.sound_assets + 1] = {
			source = source,
			target = target,
		}
	end
end

local function add_ordered(set, list, value)
	if value and value ~= '' and not set[value] then
		set[value] = true
		list[#list + 1] = value
	end
end

local function push(out, line)
	out[#out + 1] = line or ''
end

local function decrypted_bytes(data, offset)
	local key = M.KEY
	local key_len = #key
	local out = { }
	local j = 0
	for i = offset + 1, #data do
		local byte = data:byte(i)
		local key_byte = key:byte((j % key_len) + 1)
		out[#out + 1] = string.char((byte - key_byte) % 256)
		j = j + 1
	end
	return table.concat(out)
end

function M.decrypt(data)
	assert(type(data) == 'string', 'data must be a string')
	return decrypted_bytes(data, M.HEADER_SIZE)
end

function M.encrypt(text, header)
	assert(type(text) == 'string', 'text must be a string')
	header = header or string.rep('\0', M.HEADER_SIZE)
	assert(#header == M.HEADER_SIZE, 'header must be exactly 123 bytes')

	local key = M.KEY
	local key_len = #key
	local out = { header }
	for i = 1, #text do
		local key_byte = key:byte(((i - 1) % key_len) + 1)
		out[#out + 1] = string.char((text:byte(i) + key_byte) % 256)
	end
	return table.concat(out)
end

function M.decrypt_file(path)
	local data, err = read_file(path, 'rb')
	if not data then
		return nil, err
	end
	return M.decrypt(data)
end

function M.read_data_list(path)
	local text, err = read_file(path, 'rb')
	if not text then
		return nil, err
	end

	local result = { }
	for line in text:gmatch('[^\r\n]+') do
		local clean = line:gsub('#.*$', '')
		if clean:find('file%s*:') then
			local id = clean:match('id%s*:%s*(%-?%d+)')
			local object_type = clean:match('type%s*:%s*(%-?%d+)')
			local file = clean:match('file%s*:%s*(%S+)')
			if id and object_type and file then
				result[normalize_path(file):lower()] = {
					id = tonumber(id),
					type = tonumber(object_type),
					file = normalize_path(file),
				}
			end
		end
	end
	return result
end

function M.infer_type(input_path, options)
	options = options or { }
	if options.type ~= nil then
		return tostring(options.type)
	end

	local data_list = options.data_list
	if not data_list then
		local sibling = join_path(dirname(input_path), 'data.txt')
		if file_exists(sibling) then
			data_list = sibling
		end
	end
	if not data_list then
		return nil
	end

	local list = type(data_list) == 'table' and data_list or M.read_data_list(data_list)
	if not list then
		return nil
	end

	local name = basename(input_path):lower()
	for path, entry in pairs(list) do
		if basename(path):lower() == name then
			return tostring(entry.type)
		end
	end
	return nil
end

local function emit_fields(out, fields, indent, sounds, sound_set)
	local regular = { }
	local states = { }
	local sound_lines = { }
	for i = 1, #fields do
		local field = fields[i]
		local key = field.key
		local value = normalize_path(field.value)
		if key == 'state' then
			states[#states + 1] = value
		elseif key == 'sound' then
			add_ordered(sound_set, sounds, value)
			add_sound_asset(sound_set.options, value)
			sound_lines[#sound_lines + 1] = value
		else
			regular[#regular + 1] = format_field(key, format_value(value, key))
		end
	end

	if #regular > 0 then
		push(out, indent .. table.concat(regular, '  '))
	end
	for i = 1, #states do
		push(out, indent .. '<state> ' .. states[i] .. ' </state>')
	end
	for i = 1, #sound_lines do
		push(out, indent .. '<sound> ' .. sound_lines[i] .. ' </sound>')
	end
end

local function emit_structured_line(out, line, indent, sounds, sound_set)
	local fields = parse_fields(line)
	if #fields == 0 then
		push(out, indent .. trim(normalize_path(line)))
		return
	end
	emit_fields(out, fields, indent, sounds, sound_set)
end

local function convert_bitmap_line(line, header, header_keys, sounds, sound_set, options)
	local start_id, end_id, rest = line:match('^file%((%-?%d+)%s*%-%s*(%-?%d+)%)%s*:%s*(.+)$')
	if start_id then
		local path, attrs = rest:match('^(%S+)%s*(.*)$')
		local fields = parse_fields(attrs or '')
		local target = converted_sprite_path(path, options)
		add_sprite_asset(options, path, target)
		local pieces = { '<sprite>', target }
		local used = { }
		for i = 1, #fields do
			local key = fields[i].key
			if key == 'row' then
				key = 'x'
			elseif key == 'col' then
				key = 'y'
			end
			used[key] = true
			pieces[#pieces + 1] = format_field(key, format_value(fields[i].value, key))
		end
		if not used.s then
			pieces[#pieces + 1] = 's: 1'
		end
		if not used.f then
			pieces[#pieces + 1] = 'f: ' .. tostring(tonumber(end_id) - tonumber(start_id) + 1)
		end
		if not used.ord then
			pieces[#pieces + 1] = 'ord: ' .. start_id
		end
		if not used.kx then
			pieces[#pieces + 1] = 'kx: 1'
		end
		if not used.ky then
			pieces[#pieces + 1] = 'ky: 1'
		end
		pieces[#pieces + 1] = '</sprite>'
		push(header, table.concat(pieces, ' '))
		return
	end

	local fields = parse_fields(line)
	if #fields > 0 then
		for i = 1, #fields do
			local key = fields[i].key
			local value = normalize_path(fields[i].value)
			header_keys[key] = true
			if key == 'head' or key == 'small' then
				local target = converted_sprite_path(value, options)
				add_sprite_asset(options, value, target)
				value = target
			end
			if key:lower():find('sound') and value:match('%.%a+$') then
				add_ordered(sound_set, sounds, value)
				add_sound_asset(sound_set.options, value)
			end
			push(header, format_field(key, format_value(value, key)))
		end
		return
	end

	local key, value = line:match('^(%S+)%s+(.+)$')
	if key and value then
		value = normalize_path(value)
		header_keys[key] = true
		if key == 'head' or key == 'small' then
			local target = converted_sprite_path(value, options)
			add_sprite_asset(options, value, target)
			value = target
		end
		push(header, format_field(key, format_value(value, key)))
	elseif trim(line) ~= '' then
		push(header, normalize_path(trim(line)))
	end
end

function M.convert_text(text, options)
	options = options or { }
	local object_type = options.type ~= nil and tostring(options.type) or nil
	local header = { }
	local body = { }
	local sounds = { }
	local sound_set = { options = options }
	local header_keys = { }
	local mode = nil
	local active_block = nil
	local weapon_strength_open = false

	local function close_weapon_strength()
		if weapon_strength_open then
			push(body, '</weapon_strength>')
			weapon_strength_open = false
		end
	end

	for _, raw_line in ipairs(split_lines(text)) do
		local line = raw_line:gsub('%s+$', '')
		local stripped = trim(line)

		if stripped == '' then
			if mode == 'frame' or mode == 'element' or mode == 'weapon_strength' then
				push(body, '')
			end

		elseif stripped == '<bmp_begin>' then
			mode = 'bitmap'

		elseif stripped == '<bmp_end>' then
			mode = nil
			push(header, '')

		elseif stripped == '<weapon_strength_list>' then
			mode = 'weapon_strength'
			push(body, '')

		elseif stripped == '<weapon_strength_list_end>' then
			close_weapon_strength()
			mode = nil
			push(body, '')

		elseif stripped:match('^<frame>%s*') then
			mode = 'frame'
			push(body, '<frame> ' .. trim(stripped:gsub('^<frame>%s*', '')))

		elseif stripped == '<frame_end>' then
			mode = nil
			push(body, '</frame>')
			push(body, '')

		elseif mode == 'bitmap' then
			convert_bitmap_line(stripped, header, header_keys, sounds, sound_set, options)

		elseif mode == 'weapon_strength' then
			local fields = parse_fields(stripped)
			if #fields > 0 and fields[1].key == 'entry' then
				close_weapon_strength()
				push(body, '<weapon_strength> ' .. normalize_path(fields[1].value))
				weapon_strength_open = true
				if #fields > 1 then
					local rest = { }
					for i = 2, #fields do
						rest[#rest + 1] = fields[i]
					end
					emit_fields(body, rest, '   ', sounds, sound_set)
				end
			elseif weapon_strength_open then
				emit_structured_line(body, stripped, '   ', sounds, sound_set)
			else
				push(body, normalize_path(stripped))
			end

		elseif mode == 'element' then
			if stripped == active_block.name .. '_end:' then
				push(body, '   ' .. active_block.close)
				mode = 'frame'
				active_block = nil
			else
				emit_structured_line(body, stripped, '      ', sounds, sound_set)
			end

		elseif mode == 'frame' then
			local block_name = stripped:match('^([%w_]+):%s*$')
			if block_name then
				local mapped = block_map[block_name] or {
					open = '[' .. block_name .. ']',
					close = '[/' .. block_name .. ']',
				}
				active_block = {
					name = block_name,
					close = mapped.close,
				}
				push(body, '   ' .. mapped.open)
				mode = 'element'
			else
				local fields = parse_fields(stripped)
				if #fields > 0 then
					emit_fields(body, fields, '   ', sounds, sound_set)
				else
					push(body, '   ' .. normalize_path(stripped))
				end
			end

		else
			push(body, normalize_path(stripped))
		end
	end

	close_weapon_strength()

	local defaults = { }
	if not header_keys.frame then
		defaults[#defaults + 1] = 'frame: 0'
	end
	if object_type and gravity_types[object_type] and not header_keys.gravity then
		defaults[#defaults + 1] = 'gravity: true'
	end
	if object_type and shadow_types[object_type] and not header_keys.shadow then
		defaults[#defaults + 1] = 'shadow: true'
	end
	if object_type then
		defaults[#defaults + 1] = '<constate> compatibility </constate>'
	end

	local sound_lines = { }
	if object_type == '0' then
		for i = 1, #compatibility_sounds do
			local sound = compatibility_sounds[i]
			sound_lines[#sound_lines + 1] = '<sound> ' .. sound[1] .. ' ' .. sound[2] .. ' </sound>'
			add_sound_asset(options, 'data/' .. basename(sound[2]))
		end
	end
	for i = 1, #sounds do
		local id = sounds[i]
		sound_lines[#sound_lines + 1] = '<sound> ' .. id .. ' ' .. sound_target(id) .. ' </sound>'
	end

	local output = { }
	for i = 1, #header do
		push(output, header[i])
	end
	if #defaults > 0 then
		if #output > 0 and output[#output] ~= '' then
			push(output, '')
		end
		for i = 1, #defaults do
			push(output, defaults[i])
		end
	end
	if #sound_lines > 0 then
		if #output > 0 and output[#output] ~= '' then
			push(output, '')
		end
		for i = 1, #sound_lines do
			push(output, sound_lines[i])
		end
	end
	if #body > 0 then
		if #output > 0 and output[#output] ~= '' then
			push(output, '')
		end
		for i = 1, #body do
			push(output, body[i])
		end
	end

	while #output > 0 and output[#output] == '' do
		output[#output] = nil
	end
	return table.concat(output, LF) .. LF
end

local function infer_project_root(path)
	local dir = dirname(path)
	if basename(dir):lower() == 'data' then
		return dirname(dir)
	end
	return dir
end

function M.convert_image(input_path, output_path, options)
	options = options or { }
	if not file_exists(input_path) then
		return nil, 'sprite source not found: ' .. tostring(input_path)
	end
	ensure_parent_dir(output_path)
	local script = table.concat({
		'$ProgressPreference = "SilentlyContinue";',
		'Add-Type -AssemblyName System.Drawing;',
		'$src = ' .. ps_quote(input_path) .. ';',
		'$dst = ' .. ps_quote(output_path) .. ';',
		'$bmp = [System.Drawing.Bitmap]::new($src);',
		'try {',
		'  $bg = $bmp.GetPixel(0, 0);',
		'  $out = [System.Drawing.Bitmap]::new($bmp.Width, $bmp.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb);',
		'  try {',
		'    for ($y = 0; $y -lt $bmp.Height; $y++) {',
		'      for ($x = 0; $x -lt $bmp.Width; $x++) {',
		'        $c = $bmp.GetPixel($x, $y);',
		options.remove_background == false and
			'        $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $c.R, $c.G, $c.B));' or
			'        if ($c.R -eq $bg.R -and $c.G -eq $bg.G -and $c.B -eq $bg.B) { $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $c.R, $c.G, $c.B)); } else { $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $c.R, $c.G, $c.B)); }',
		'      }',
		'    }',
		'    $out.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png);',
		'  } finally { $out.Dispose(); }',
		'} finally { $bmp.Dispose(); }',
	}, ' ')
	local command = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand ' .. base64_encode(utf16le_ascii(script))
	local result, why, code = os.execute(command)
	if not command_ok(result, why, code) then
		return nil, 'sprite conversion failed: ' .. tostring(input_path)
	end
	return true
end

function M.copy_sprites(sprite_assets, input_root, output_root, options)
	options = options or { }
	sprite_assets = sprite_assets or { }
	local copied = options.copied_sprites or { }
	options.copied_sprites = copied
	local count = 0
	for i = 1, #sprite_assets do
		local asset = sprite_assets[i]
		local source = join_relative(input_root, asset.source)
		local target = join_relative(output_root, asset.target)
		if not copied[asset.target] then
			local ok, err = M.convert_image(source, target, options)
			if not ok then
				return nil, err
			end
			copied[asset.target] = true
			count = count + 1
		end
	end
	return count
end

function M.copy_sounds(sound_assets, input_root, output_root, options)
	options = options or { }
	sound_assets = sound_assets or { }
	local copied = options.copied_sounds or { }
	options.copied_sounds = copied
	local count = 0
	for i = 1, #sound_assets do
		local asset = sound_assets[i]
		local source = join_relative(input_root, asset.source)
		local target = join_relative(output_root, asset.target)
		if not copied[asset.target] then
			local ok, err = copy_file(source, target)
			if not ok then
				return nil, 'sound source not found: ' .. tostring(source) .. (err and (' (' .. err .. ')') or '')
			end
			copied[asset.target] = true
			count = count + 1
		end
	end
	return count
end

function M.convert_file(input_path, output_path, options)
	options = options or { }
	local object_type = M.infer_type(input_path, options)
	local text, err = M.decrypt_file(input_path)
	if not text then
		return nil, err
	end

	local sprite_assets = { }
	local sound_assets = { }
	local converted = M.convert_text(text, {
		type = object_type,
		copy_sprites = options.copy_sprites,
		copy_sounds = options.copy_sounds,
		copy_assets = options.copy_assets,
		sprite_assets = sprite_assets,
		sound_assets = sound_assets,
	})
	if output_path then
		ensure_parent_dir(output_path)
		local ok, write_err = write_file(output_path, converted, 'wb')
		if not ok then
			return nil, write_err
		end
	end
	if options.copy_sprites or options.copy_assets then
		local input_root = options.input_root or infer_project_root(input_path)
		local output_root = options.output_root or output_path and infer_project_root(output_path)
		if not output_root then
			return nil, 'output_root is required when asset copying is enabled without output_path'
		end
		local ok, copy_err = M.copy_sprites(sprite_assets, input_root, output_root, {
			copied_sprites = options.copied_sprites,
			remove_background = options.remove_background,
		})
		if not ok then
			return nil, copy_err
		end
	end
	if options.copy_sounds or options.copy_assets then
		local input_root = options.input_root or infer_project_root(input_path)
		local output_root = options.output_root or output_path and infer_project_root(output_path)
		if not output_root then
			return nil, 'output_root is required when asset copying is enabled without output_path'
		end
		local ok, copy_err = M.copy_sounds(sound_assets, input_root, output_root, {
			copied_sounds = options.copied_sounds,
		})
		if not ok then
			return nil, copy_err
		end
	end
	return converted
end

local function parse_options(args, start)
	local options = { _positionals = { } }
	for i = start or 1, #args do
		local argi = args[i]
		local key, value = argi:match('^%-%-([^=]+)=(.*)$')
		if key then
			key = key:gsub('%-', '_')
			options[key] = value
		elseif argi:match('^%-%-') then
			key = argi:gsub('^%-%-', ''):gsub('%-', '_')
			options[key] = true
		else
			options._positionals[#options._positionals + 1] = argi
		end
	end
	return options
end

local function usage()
	return table.concat({
		'Usage:',
		'  luajit tools/lf2dat.lua decrypt <input.dat> [output.txt]',
		'  luajit tools/lf2dat.lua convert <input.dat> <output.dat> [--type=N] [--data-list=PATH] [--copy-sprites] [--copy-sounds] [--copy-assets]',
		'  luajit tools/lf2dat.lua batch <input_dir> <output_dir> [--data-list=PATH] [--copy-sprites] [--copy-sounds] [--copy-assets]',
		'',
		'Converts original encrypted Little Fighter 2 DAT files to unencrypted',
		'L2DF/LFFS2-style data. See docs/guide/11-lf2-dat-reference.md for',
		'additional LF2 DAT format notes.',
	}, LF)
end

local function list_dat_files(dir)
	local files = { }
	local cmd
	if path_sep == '\\' then
		cmd = ('dir /b /a-d "%s\\*.dat"'):format(dir:gsub('"', '\\"'))
	else
		cmd = ('find "%s" -maxdepth 1 -type f -name "*.dat" -printf "%%f\\n"'):format(dir:gsub('"', '\\"'))
	end
	local pipe = io.popen(cmd)
	if not pipe then
		return files
	end
	for file in pipe:lines() do
		files[#files + 1] = file
	end
	pipe:close()
	table.sort(files)
	return files
end

function M.batch(input_dir, output_dir, options)
	options = options or { }
	make_dir(output_dir)
	local data_list = options.data_list
	if not data_list then
		local default_list = join_path(input_dir, 'data.txt')
		if file_exists(default_list) then
			data_list = default_list
		end
	end
	local parsed_data_list = data_list and M.read_data_list(data_list) or nil
	local input_root = options.input_root or infer_project_root(input_dir)
	local output_root = options.output_root or infer_project_root(output_dir)
	local copied_sprites = options.copied_sprites or { }
	local copied_sounds = options.copied_sounds or { }
	local count = 0
	for _, file in ipairs(list_dat_files(input_dir)) do
		local input_path = join_path(input_dir, file)
		local output_path = join_path(output_dir, file)
		local converted, err = M.convert_file(input_path, output_path, {
			data_list = parsed_data_list,
			copy_sprites = options.copy_sprites,
			copy_sounds = options.copy_sounds,
			copy_assets = options.copy_assets,
			input_root = input_root,
			output_root = output_root,
			copied_sprites = copied_sprites,
			copied_sounds = copied_sounds,
		})
		if not converted then
			return nil, err
		end
		count = count + 1
	end
	return count
end

function M.main(argv)
	local command = argv[1]
	if not command or command == '-h' or command == '--help' or command == 'help' then
		io.stdout:write(usage(), LF)
		return 0
	end

	if command == 'decrypt' then
		local input_path = argv[2]
		local output_path = argv[3]
		if not input_path then
			io.stderr:write(usage(), LF)
			return 1
		end
		local text, err = M.decrypt_file(input_path)
		if not text then
			io.stderr:write(err, LF)
			return 1
		end
		if output_path then
			local ok, write_err = write_file(output_path, text, 'wb')
			if not ok then
				io.stderr:write(write_err, LF)
				return 1
			end
		else
			io.stdout:write(text)
		end
		return 0
	elseif command == 'convert' then
		local options = parse_options(argv, 4)
		local input_path = argv[2]
		local output_path = argv[3]
		if not input_path or not output_path then
			io.stderr:write(usage(), LF)
			return 1
		end
		local ok, err = M.convert_file(input_path, output_path, {
			type = options.type,
			data_list = options.data_list,
			copy_sprites = options.copy_sprites,
			copy_sounds = options.copy_sounds,
			copy_assets = options.copy_assets,
			input_root = options.input_root,
			output_root = options.output_root,
		})
		if not ok then
			io.stderr:write(err, LF)
			return 1
		end
		return 0
	elseif command == 'batch' then
		local options = parse_options(argv, 4)
		local input_dir = argv[2]
		local output_dir = argv[3]
		if not input_dir or not output_dir then
			io.stderr:write(usage(), LF)
			return 1
		end
		local ok, err = M.batch(input_dir, output_dir, {
			data_list = options.data_list,
			copy_sprites = options.copy_sprites,
			copy_sounds = options.copy_sounds,
			copy_assets = options.copy_assets,
			input_root = options.input_root,
			output_root = options.output_root,
		})
		if not ok then
			io.stderr:write(err, LF)
			return 1
		end
		return 0
	end

	io.stderr:write('Unknown command: ', tostring(command), LF, usage(), LF)
	return 1
end

if _G.arg and _G.arg[0] and _G.arg[0]:gsub('\\', '/'):match('lf2dat%.lua$') then
	os.exit(M.main(_G.arg))
end

return M
