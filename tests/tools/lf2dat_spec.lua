require 'spec_helper'

local Converter = require 'tools.lf2dat'
local LffsParser = l2df.import 'class.parser.lffs2'

local function read_file(path)
	local file = assert(io.open(path, 'rb'))
	local data = file:read('*a')
	file:close()
	return data
end

local function file_exists(path)
	local file = io.open(path, 'rb')
	if file then
		file:close()
		return true
	end
	return false
end

local function find_by_first(items, value)
	for i = 1, #items do
		if items[i][1] == value then
			return items[i]
		end
	end
end

local function find_frame_with(frames, field)
	for i = 1, #frames do
		if frames[i][field] then
			return frames[i]
		end
	end
end

describe('tools.lf2dat', function()
	it('decrypts original LF2 DAT text', function()
		local decrypted = assert(Converter.decrypt_file('dev/little-fighter/data/template.dat'))

		assert.are.equal('<bmp_begin>', decrypted:sub(1, 11))
		assert.is_truthy(decrypted:find('name:%s*Template'))
	end)

	it('converts character data into parseable LFFS2 output', function()
		local decrypted = assert(Converter.decrypt_file('dev/little-fighter/data/template.dat'))
		local converted = Converter.convert_text(decrypted, { type = 0 })
		local parsed = LffsParser:new():parse(converted)

		assert.are.equal('Template', parsed.name)
		assert.are.equal('sprite/template1/face.bmp', parsed.head)
		assert.are.equal('sprite/template1/s.bmp', parsed.small)
		assert.are.equal(2, #parsed.sprites)
		assert.are.equal('sprite/template1/0.bmp', parsed.sprites[1][1])
		assert.are.equal(79, parsed.sprites[1].w)
		assert.are.equal(10, parsed.sprites[1].x)
		assert.are.equal(7, parsed.sprites[1].y)
		assert.are.equal(1, parsed.sprites[1].s)
		assert.are.equal(70, parsed.sprites[1].f)
		assert.are.equal(0, parsed.sprites[1].ord)
		assert.are.equal(1, parsed.sprites[1].kx)
		assert.are.equal(1, parsed.sprites[1].ky)
		assert.is_nil(parsed.sprites[1].row)
		assert.is_nil(parsed.sprites[1].col)
		assert.is_nil(parsed.sprites[1].from)
		assert.is_nil(parsed.sprites[1].to)
		assert.is_true(parsed.gravity)
		assert.is_true(parsed.shadow)
		assert.are.equal('compatibility', parsed.constates[1][1])

		assert.is_truthy(find_by_first(parsed.sounds, 'punch'))
		assert.are.equal('data/sounds/003.wav', find_by_first(parsed.sounds, 'data/003.wav')[2])

		local first = parsed.frames[1]
		assert.are.equal(0, first[1])
		assert.are.equal('standing', first[2])
		assert.are.equal(0, first.states[1][1])
		assert.are.equal(1, first.wpoint.kind)
		assert.are.equal(0, first.bodies[1].kind)

		local itr_frame = assert(find_frame_with(parsed.frames, 'itrs'))
		assert.is_number(itr_frame.itrs[1].kind)
		local cpoint_frame = assert(find_frame_with(parsed.frames, 'cpoint'))
		assert.is_number(cpoint_frame.cpoint.kind)

		assert.is_truthy(converted:find('<sound> data/003%.wav </sound>', 1, false))
		assert.is_truthy(converted:find('%[wpoint%]'))
		assert.is_truthy(converted:find('%[cpoint%]'))
	end)

	it('rewrites and registers sprite paths when copy-sprites is enabled', function()
		local decrypted = assert(Converter.decrypt_file('dev/little-fighter/data/davis.dat'))
		local sprite_assets = { }
		local converted = Converter.convert_text(decrypted, {
			type = 0,
			copy_sprites = true,
			sprite_assets = sprite_assets,
		})
		local parsed = LffsParser:new():parse(converted)

		assert.are.equal('sprite/sys/davis_f.png', parsed.head)
		assert.are.equal('sprite/sys/davis_s.png', parsed.small)
		assert.are.equal('sprite/sys/davis_0.png', parsed.sprites[1][1])
		assert.are.equal(5, #sprite_assets)
		assert.are.equal('sprite/sys/davis_f.bmp', sprite_assets[1].source)
		assert.are.equal('sprite/sys/davis_f.png', sprite_assets[1].target)
	end)

	it('exports LF2 bitmap sprites as PNG files', function()
		local temp_root = (os.getenv('TEMP') or os.getenv('TMP') or '.'):gsub('\\', '/') .. '/l2df-lf2dat-spec'
		local output = temp_root .. '/sprite/sys/davis_0.png'

		local ok, err = Converter.copy_sprites({
			{ source = 'sprite/sys/davis_0.bmp', target = 'sprite/sys/davis_0.png' },
		}, 'dev/little-fighter', temp_root)

		assert.is_truthy(ok, err)
		assert.is_true(file_exists(output))
		assert.are.equal('\137PNG\r\n\026\n', read_file(output):sub(1, 8))
	end)

	it('copies sprites and sounds when copy-assets is enabled', function()
		local temp_root = (os.getenv('TEMP') or os.getenv('TMP') or '.'):gsub('\\', '/') .. '/l2df-lf2dat-assets-spec'
		local output = temp_root .. '/data/weapon0.dat'

		local converted, err = Converter.convert_file('dev/little-fighter/data/weapon0.dat', output, {
			data_list = 'dev/little-fighter/data/data.txt',
			copy_assets = true,
			input_root = 'dev/little-fighter',
			output_root = temp_root,
		})

		assert.is_truthy(converted, err)
		assert.is_true(file_exists(output))
		assert.is_true(file_exists(temp_root .. '/sprite/sys/weapon0.png'))
		assert.is_true(file_exists(temp_root .. '/data/sounds/011.wav'))
		assert.are.equal('\137PNG\r\n\026\n', read_file(temp_root .. '/sprite/sys/weapon0.png'):sub(1, 8))
	end)

	it('infers object type from LF2 data.txt', function()
		assert.are.equal('0', Converter.infer_type('dev/little-fighter/data/template.dat'))
		assert.are.equal('3', Converter.infer_type('dev/little-fighter/data/john_ball.dat'))
	end)

	it('preserves weapon strength entries as parseable blocks', function()
		local decrypted = assert(Converter.decrypt_file('dev/little-fighter/data/weapon0.dat'))
		local converted = Converter.convert_text(decrypted, { type = 1 })
		local parsed = LffsParser:new():parse(converted)

		assert.are.equal(4, #parsed.weapon_strengthes)
		assert.are.equal(1, parsed.weapon_strengthes[1][1])
		assert.are.equal('normal', parsed.weapon_strengthes[1][2])
		assert.are.equal(40, parsed.weapon_strengthes[1].fall)
		assert.are.equal('data/sounds/011.wav', find_by_first(parsed.sounds, 'data/011.wav')[2])
	end)

	it('loads and runs without a Love2D runtime dependency', function()
		assert.is_nil(_G.love)
		local encrypted = Converter.encrypt('<bmp_begin>\n')
		assert.are.equal('<bmp_begin>\n', Converter.decrypt(encrypted))
	end)
end)
