-- check-links.lua
-- Check that "@key" links in Markdown files match definitions in a links file.
--
-- Usage: lua check-links.lua LINKS_FILE MARKDOWN_FILE...
--
-- The links file contains one definition per line:
--   [link-key]: url
-- Markdown files use those definitions as:
--   [text](@link-key)
--
-- The script reports links that are used but not defined (along with the file
-- that uses each one) and links that are defined but not used. It exits with
-- a non-zero status if either report is non-empty.

local function fail(msg)
  io.stderr:write("check-links.lua: " .. msg .. "\n")
  os.exit(2)
end

local function usage()
  fail("usage: lua check-links.lua LINKS_FILE MARKDOWN_FILE...")
end

local function open_file(path)
  local f = io.open(path, "r")
  if not f then
    fail("cannot open " .. path)
  end
  return f
end

local function read_file(path)
  local f = open_file(path)
  local content = f:read("*a")
  f:close()
  return content
end

local function read_lines(path)
  local f = open_file(path)
  local lines = {}
  for line in f:lines() do
    lines[#lines + 1] = line
  end
  f:close()
  return lines
end

-- Returns the key from a "[key]: url" definition line, or nil if it is not one.
local function definition_key(line)
  return line:match("^%[([%w-]+)%]:%s*%S+%s*$")
end

-- Returns the defined keys in file order, and a set of those keys.
local function read_links_file(path)
  local order = {}
  local set = {}
  for _, line in ipairs(read_lines(path)) do
    local key = definition_key(line)
    if key then
      order[#order + 1] = key
      set[key] = true
    end
  end
  return order, set
end

-- Records every "@key" link in content as used in path.
local function add_used_links(content, path, set, files)
  for key in content:gmatch("%]%(@([%w-]+)%)") do
    set[key] = true
    files[key] = files[key] or {}
    files[key][path] = true
  end
end

-- Returns a set of used keys and a map of each key to the files using it.
local function read_markdown_files(paths)
  local set = {}
  local files = {}
  for _, path in ipairs(paths) do
    add_used_links(read_file(path), path, set, files)
  end
  return set, files
end

-- Returns the keys of a map as a sorted array.
local function sorted_keys(map)
  local keys = {}
  for key in pairs(map) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

-- Returns used keys that have no definition.
local function missing_keys(defined_set, used_files)
  local missing = {}
  for _, key in ipairs(sorted_keys(used_files)) do
    if not defined_set[key] then
      missing[#missing + 1] = key
    end
  end
  return missing
end

-- Returns defined keys that are never used.
local function unused_keys(defined_order, used_set)
  local unused = {}
  for _, key in ipairs(defined_order) do
    if not used_set[key] then
      unused[#unused + 1] = key
    end
  end
  return unused
end

-- Reports used-but-undefined keys; returns true if any were found.
local function report_missing(defined_set, used_files)
  local missing = missing_keys(defined_set, used_files)
  if #missing == 0 then
    return false
  end
  print("used but not defined:")
  for _, key in ipairs(missing) do
    for _, path in ipairs(sorted_keys(used_files[key])) do
      print(("  %s: %s"):format(key, path))
    end
  end
  return true
end

-- Reports defined-but-unused keys; returns true if any were found.
local function report_unused(defined_order, used_set)
  local unused = unused_keys(defined_order, used_set)
  if #unused == 0 then
    return false
  end
  print("defined but not used:")
  for _, key in ipairs(unused) do
    print("  " .. key)
  end
  return true
end

if #arg < 2 then
  usage()
end

local defined_order, defined_set = read_links_file(arg[1])

local markdown_files = {}
for i = 2, #arg do
  markdown_files[#markdown_files + 1] = arg[i]
end
local used_set, used_files = read_markdown_files(markdown_files)

local problems = false
if report_missing(defined_set, used_files) then
  problems = true
end
if report_unused(defined_order, used_set) then
  problems = true
end

if problems then
  os.exit(1)
end
