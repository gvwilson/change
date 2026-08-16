-- inc-noh1.lua
-- A shortcode like Quarto's {{< include >}}, but it strips the first level-1
-- heading from the included file (so the including chapter supplies its own
-- title). The included file is otherwise standalone Markdown; the only extra
-- rewrite needed is the internal book link @/slug/ -> ../slug/index.qmd.

return {
  ["inc-noh1"] = function(args, kwargs, meta)
    local rel = pandoc.utils.stringify(args[1])
    local input = quarto.doc.input_file
    local dir = input and (input:match("^(.*/)") or ".") or "."
    local f = assert(io.open(dir .. rel, "r"), "inc-noh1: cannot open " .. rel)
    local content = f:read("*all")
    f:close()
    content = content:gsub("^%s*#%s+[^\n]*\n", "", 1)
    content = content:gsub("%]%(@/([%w-]+)/%)", "](../%1/index.qmd)")
    return pandoc.read(content, "markdown").blocks
  end
}
