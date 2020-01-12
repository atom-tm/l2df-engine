--[[
 * Copyright (c) 2015-2020 Iryont <https://github.com/iryont/lua-struct>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
]]

local tonumber = _G.tonumber
local tostring = _G.tostring
local unpack = table.unpack or _G.unpack
local tremove = table.remove
local tconcat = table.concat
local floor = math.floor
local ldexp = math.ldexp
local frexp = math.frexp
local strlen = string.len
local strsub = string.sub
local strrep = string.rep
local strbyte = string.byte
local strchar = string.char
local strfind = string.find
local strmatch = string.match
local strreverse = string.reverse

local packer = { }

function packer.pack(format, ...)
  local stream = { }
  local vars = {...}
  local endianness = true

  for i = 1, strlen(format) do
    local opt = strsub(format, i, i)

    if opt == '<' then
      endianness = true
    elseif opt == '>' then
      endianness = false
    elseif strfind(opt, '[bBhHiIlL]') then
      local n = strfind(opt, '[hH]') and 2 or strfind(opt, '[iI]') and 4 or strfind(opt, '[lL]') and 8 or 1
      local val = tonumber(tremove(vars, 1))

      local bytes = { }
      for j = 1, n do
        bytes[j] = strchar(val % 256)
        val = floor(val / 256)
      end

      if not endianness then
        stream[#stream + 1] = strreverse(tconcat(bytes))
      else
        stream[#stream + 1] = tconcat(bytes)
      end
    elseif strfind(opt, '[fd]') then
      local val = tonumber(tremove(vars, 1))
      local sign = 0

      if val < 0 then
        sign = 1
        val = -val
      end

      local mantissa, exponent = frexp(val)
      if val == 0 then
        mantissa = 0
        exponent = 0
      else
        mantissa = (mantissa * 2 - 1) * ldexp(0.5, (opt == 'd') and 53 or 24)
        exponent = exponent + ((opt == 'd') and 1022 or 126)
      end

      local bytes = { }
      if opt == 'd' then
        val = mantissa
        for i = 1, 6 do
          bytes[i] = strchar(floor(val) % 256)
          val = floor(val / 256)
        end
      else
        bytes[1] = strchar(floor(mantissa) % 256)
        val = floor(mantissa / 256)
        bytes[2] = strchar(floor(val) % 256)
        val = floor(val / 256)
      end

      bytes[#bytes + 1] = strchar(floor(exponent * ((opt == 'd') and 16 or 128) + val) % 256)
      val = floor((exponent * ((opt == 'd') and 16 or 128) + val) / 256)
      bytes[#bytes + 1] = strchar(floor(sign * 128 + val) % 256)
      val = floor((sign * 128 + val) / 256)

      if not endianness then
        stream[#stream + 1] = strreverse(tconcat(bytes))
      else
        stream[#stream + 1] = tconcat(bytes)
      end
    elseif opt == 's' then
      stream[#stream + 1] = tostring(tremove(vars, 1))
      stream[#stream + 1] = strchar(0)
    elseif opt == 'c' then
      local n = strmatch(strsub(format, i + 1), '%d+')
      local length = tonumber(n)

      if length > 0 then
        local str = tostring(tremove(vars, 1))
        if length - strlen(str) > 0 then
          str = str .. strrep(' ', length - strlen(str))
        end
        stream[#stream + 1] = strsub(str, 1, length)
      end
      i = i + strlen(n)
    end
  end

  return tconcat(stream)
end

function packer.unpack(format, stream, pos)
  local vars = { }
  local iterator = pos or 1
  local endianness = true

  for i = 1, strlen(format) do
    local opt = strsub(format, i, i)

    if opt == '<' then
      endianness = true
    elseif opt == '>' then
      endianness = false
    elseif strfind(opt, '[bBhHiIlL]') then
      local n = strfind(opt, '[hH]') and 2 or strfind(opt, '[iI]') and 4 or strfind(opt, '[lL]') and 8 or 1
      local signed = opt:lower() == opt

      local val = 0
      for j = 1, n do
        local byte = strbyte(strsub(stream, iterator, iterator))
        if endianness then
          val = val + byte * (2 ^ ((j - 1) * 8))
        else
          val = val + byte * (2 ^ ((n - j) * 8))
        end
        iterator = iterator + 1
      end

      if signed and val >= 2 ^ (n * 8 - 1) then
        val = val - 2 ^ (n * 8)
      end

      vars[#vars + 1] = floor(val)
    elseif strfind(opt, '[fd]') then
      local n = (opt == 'd') and 8 or 4
      local x = strsub(stream, iterator, iterator + n - 1)
      iterator = iterator + n

      if not endianness then
        x = strreverse(x)
      end

      local sign = 1
      local mantissa = strbyte(x, (opt == 'd') and 7 or 3) % ((opt == 'd') and 16 or 128)
      for i = n - 2, 1, -1 do
        mantissa = mantissa * 256 + strbyte(x, i)
      end

      if strbyte(x, n) > 127 then
        sign = -1
      end

      local exponent = (strbyte(x, n) % 128) * ((opt == 'd') and 16 or 2) + floor(strbyte(x, n - 1) / ((opt == 'd') and 16 or 128))
      if exponent == 0 then
        vars[#vars + 1] = 0.0
      else
        mantissa = (ldexp(mantissa, (opt == 'd') and -52 or -23) + 1) * sign
        vars[#vars + 1] = ldexp(mantissa, exponent - ((opt == 'd') and 1023 or 127))
      end
    elseif opt == 's' then
      local bytes = { }
      for j = iterator, strlen(stream) do
        if strsub(stream, j, j) == strchar(0) then
          break
        end

        bytes[j - iterator + 1] = strsub(stream, j, j)
      end

      local str = tconcat(bytes)
      iterator = iterator + strlen(str) + 1
      vars[#vars + 1] = str
    elseif opt == 'c' then
      local n = strsub(format, i + 1):match('%d+')
      vars[#vars + 1] = strsub(stream, iterator, iterator + tonumber(n)-1)
      iterator = iterator + tonumber(n)
      i = i + strlen(n)
    end
  end

  return unpack(vars)
end

return packer
