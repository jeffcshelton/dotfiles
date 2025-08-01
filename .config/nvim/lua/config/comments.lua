local function convert_comment(style)
  -- Find the enclosing comment.
  local current = vim.api.nvim_get_current_line()
  local node = vim.treesitter.get_node()
  local start_row, start_col, end_row, end_col

  while node do
    if node:type() == "comment" then
      start_row, start_col, end_row, end_col = node:range()
      break
    end

    node = node:parent()
  end

  if not node then
    vim.api.nvim_echo(
      { { "No comment found.", "ErrorMsg" } },
      true,
      { err = true }
    )

    return
  end

  -- Use the current line's indentation as the entire comment's indentation.
  local indent = current:match("^(%s*) %*") or current:match("^(%s*)/")
  local dominant = indent ~= nil

  if not indent then
    indent = ""
  end

  -- Get the text of the comment node as-is.
  local node_text = vim.api.nvim_buf_get_text(
    0,
    start_row,
    start_col,
    end_row,
    end_col,
    {}
  )

  -- Use the leading characters to determine the type of comment.
  local leader = node_text[1]:sub(1, 2)
  local out = {}

  if leader == "//" then
    local pattern = "^%s*//"
    local current_line = vim.api.nvim_get_current_line()

    -- If this comment line is not inline, scan for neighboring lines.
    if current_line:match(pattern) then
      local n = vim.fn.line(".")
      local line = vim.fn.getline(n)

      -- Locate the top of the comment.
      while vim.fn.getline(n - 1):match(pattern) do
        n = n - 1
      end

      start_row = n - 1

      -- Add lines to the comment until the line is no long a comment.
      while true do
        line = vim.fn.getline(n)
        line = line:match("^%s*//(.*)$")

        if not line then
          break
        end

        table.insert(out, line)
        n = n + 1
      end

      end_row = n - 2
    else
      -- If the comment is inline, use it in isolation.
      local comment = node_text[1]:match("//(.*)$")
      table.insert(out, comment)
    end
  elseif leader == "/*" then
    for i, line in ipairs(node_text) do
      -- Do not add comment lines if they're just the starting or ending blocks.
      local remove = (
        (i == 1 and line:match("^%s*/%*+%s*$"))
        or (i == #node_text and line:match("^%s*%*+/%s*$"))
      )

      if not remove then
        -- Replace instances of ` *` with `//` for later standardization.
        -- Also handle single-line block comments.
        local block = line:match("^%s* %*(.*)$")
        local single = line:match("^%s*/%*+(.*)%*+/%s*$")
        local default = line:match("^%s*(.*)$")

        if block then
          line = block
        elseif single then
          line = single
        else
          line = default
        end

        table.insert(out, line)
      end
    end
  end

  -- Trim leading and trailing whitespace from all comments.
  for i, line in ipairs(out) do
    out[i] = line:match("^%s*(.-)%s*$")
  end

  -- Format the comment according to the specified target style.
  if style == "block" or style == "doc" then
    local start = style == "block" and "/*" or "/**"

    if #out > 1 then
      for i, line in ipairs(out) do
        if line ~= "" then
          out[i] = indent .. " * " .. line
        else
          out[i] = indent .. " *"
        end
      end

      table.insert(out, 1, indent .. start)
      table.insert(out, indent .. " */")
    else
      out[1] = indent .. start .. " " .. out[1] .. " */"
    end
  elseif style == "slash" then
    for i, line in ipairs(out) do
      if line ~= "" then
        out[i] = indent .. "// " .. line
      else
        out[i] = indent .. "//"
      end
    end
  else
    vim.api.nvim_echo(
      { { "Unrecognized comment style.", "ErrorMsg" } },
      true,
      { err = true }
    )

    return
  end

  -- If there is an indentation to be applied, then the replacement should
  -- overwrite any existing indentation.
  if dominant then
    start_col = 0
    end_col = -1
  end

  vim.api.nvim_buf_set_text(
    0,
    start_row,
    start_col,
    end_row,
    end_col,
    out
  )
end

-- Convenience functions that can be used to indirectly call the universal
-- `convert_comment` function.

function CommentBlock()
  convert_comment("block")
end

function CommentDoc()
  convert_comment("doc")
end

function CommentSlash()
  convert_comment("slash")
end

vim.keymap.set("n", "<leader>cb", ":lua vim.schedule(CommentBlock)<CR>")
vim.keymap.set("n", "<leader>cd", ":lua vim.schedule(CommentDoc)<CR>")
vim.keymap.set("n", "<leader>cs", ":lua vim.schedule(CommentSlash)<CR>")
