-- check-bib.lua
-- Check that citation keys in Quarto Markdown files match entries in a
-- BibTeX file.
--
-- Usage: lua check-bib.lua BIB_FILE MARKDOWN_FILE...
--
-- The BibTeX file contains one entry per line that starts with:
--   @type{key
-- Markdown files cite those entries as:
--   [@key]
--   [@key1; @key2; @key3]
--
-- The script reports keys that are cited but not defined (along with the file
-- that cites each one) and keys that are defined but not cited. It exits with
-- a non-zero status if either report is non-empty.

local function fail(msg)
  io.stderr:write("check-bib.lua: " .. msg .. "\n")
  os.exit(2)
end

local function usage()
  fail("usage: lua check-bib.lua BIB_FILE MARKDOWN_FILE...")
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

-- Returns the key from an "@type{key" entry line, or nil if it is not one.
local function entry_key(line)
  return line:match("^@%a+%s*{%s*([^,%s]+)")
end

-- Returns the defined keys in file order, and a set of those keys.
local function read_bib_file(path)
  local order = {}
  local set = {}
  for _, line in ipairs(read_lines(path)) do
    local key = entry_key(line)
    if key then
      order[#order + 1] = key
      set[key] = true
    end
  end
  return order, set
end

-- Records every "@key" citation in content as cited in path.
local function add_cited_keys(content, path, set, files)
  for bracket in content:gmatch("%[([^%]]*)%]") do
    for key in bracket:gmatch("@([%w-]+)") do
      set[key] = true
      files[key] = files[key] or {}
      files[key][path] = true
    end
  end
end

-- Returns a set of cited keys and a map of each key to the files citing it.
local function read_markdown_files(paths)
  local set = {}
  local files = {}
  for _, path in ipairs(paths) do
    add_cited_keys(read_file(path), path, set, files)
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

-- Returns cited keys that have no definition.
local function missing_keys(defined_set, cited_files)
  local missing = {}
  for _, key in ipairs(sorted_keys(cited_files)) do
    if not defined_set[key] then
      missing[#missing + 1] = key
    end
  end
  return missing
end

-- Returns defined keys that are never cited.
local function uncited_keys(defined_order, cited_set)
  local uncited = {}
  for _, key in ipairs(defined_order) do
    if not cited_set[key] then
      uncited[#uncited + 1] = key
    end
  end
  return uncited
end

-- Reports cited-but-undefined keys; returns true if any were found.
local function report_missing(defined_set, cited_files)
  local missing = missing_keys(defined_set, cited_files)
  if #missing == 0 then
    return false
  end
  print("cited but not defined:")
  for _, key in ipairs(missing) do
    for _, path in ipairs(sorted_keys(cited_files[key])) do
      print(("  %s: %s"):format(key, path))
    end
  end
  return true
end

-- Reports defined-but-uncited keys; returns true if any were found.
local function report_uncited(defined_order, cited_set)
  local uncited = uncited_keys(defined_order, cited_set)
  if #uncited == 0 then
    return false
  end
  print("defined but not cited:")
  for _, key in ipairs(uncited) do
    print("  " .. key)
  end
  return true
end

if #arg < 2 then
  usage()
end

local defined_order, defined_set = read_bib_file(arg[1])

local markdown_files = {}
for i = 2, #arg do
  markdown_files[#markdown_files + 1] = arg[i]
end
local cited_set, cited_files = read_markdown_files(markdown_files)

local problems = false
if report_missing(defined_set, cited_files) then
  problems = true
end
if report_uncited(defined_order, cited_set) then
  problems = true
end

if problems then
  os.exit(1)
end
