-- check-glossary.lua
-- Check that glossary shortcode references in Markdown files match entries
-- in a glossary file.
--
-- Usage: lua check-glossary.lua GLOSSARY_FILE MARKDOWN_FILE...
--
-- The glossary file defines one entry per line as a span with an id:
--   <span id="key">display text</span>
-- Markdown files reference those entries with the shortcode:
--   {{<g key "display text" >}}
--
-- The script reports keys that are used but not defined (along with the file
-- that uses each one) and keys that are defined but not used. It exits with
-- a non-zero status if either report is non-empty.

local script_dir = arg[0] and arg[0]:match("^(.*)/") or "."
package.path = script_dir .. "/?.lua;" .. package.path

local utils = require("utils")
utils.program = "check-glossary.lua"

-- Returns the defined keys in file order, and a set of those keys.
local function read_glossary_file(path)
  local order = {}
  local set = {}
  for key in (utils.read_file(path)):gmatch('<span id="([%w_-]+)">') do
    order[#order + 1] = key
    set[key] = true
  end
  return order, set
end

-- Records every glossary key referenced by a "g" shortcode in content.
local function add_used_keys(content, path, set, files)
  for key in content:gmatch("{{<%s*g%s+([%w_-]+)") do
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
    add_used_keys(utils.read_file(path), path, set, files)
  end
  return set, files
end

if #arg < 2 then
  utils.fail("usage: lua check-glossary.lua GLOSSARY_FILE MARKDOWN_FILE...")
end

local defined_order, defined_set = read_glossary_file(arg[1])

local markdown_files = {}
for i = 2, #arg do
  markdown_files[#markdown_files + 1] = arg[i]
end
local used_set, used_files = read_markdown_files(markdown_files)

local problems = false
if utils.report_missing(defined_set, used_files, "used but not defined:") then
  problems = true
end
if utils.report_unused(defined_order, used_set, "defined but not used:") then
  problems = true
end

if problems then
  os.exit(1)
end
