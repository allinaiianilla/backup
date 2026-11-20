-- 1. 全自动下载并安装 lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 颜色和字体基础设置
vim.opt.termguicolors = true

-- 2. 常规设置
vim.opt.mouse = "a"
vim.opt.number = true        -- 显示行号
vim.opt.relativenumber = true -- 显示相对行号
vim.opt.hlsearch = true      -- 搜索高亮
vim.opt.incsearch = true     -- 边输入边高亮
vim.opt.ignorecase = true    -- 搜索忽略大小写
vim.opt.smartcase = true     -- 但输入大写时区分大小写

-- 2.1 Python 常用设置：4 空格缩进、tab 转空格、自动缩进
vim.opt.expandtab = true     -- 用空格代替 tab
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.autoindent = true

-- Python 文件强制 4 空格缩进（只作用于 python，不影响其他文件类型）
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.opt.clipboard = "unnamedplus"
-- vim.keymap.set("n","<leftMouse>","<leftMouse>i")
vim.keymap.set("i", "<C-l>", "<Right>")
-- 窗口左右跳转
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
-- 窗口上下跳转
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })


-- 3. 插件安装（删除了设置给环境变量），下面各插件配置

-- toggleterm 配置函数（必须先定义再被 tablesetup 引用）
local function config_toggleterm()
  require("toggleterm").setup({
    size = 8,
    open_mapping = [[<C-\>]],
    direction = "horizontal",
    start_in_insert = true,
    persist_mode = false, -- 每次打开终端都强制进入输入模式, 不记忆上次的普通模式状态
  })
  -- \t 开关终端
  vim.keymap.set('n', '<Leader>t', '<Cmd>ToggleTerm<CR>', { silent = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    callback = function()
      if vim.bo.buftype == "terminal" then
        vim.cmd("startinsert")
      end
    end,
  })

  local last_python_buf = nil

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    callback = function()
      if vim.bo.filetype == "python" then
        last_python_buf = vim.api.nvim_get_current_buf()
      end
    end,
  })

  local function run_python()
    if vim.bo.buftype == "terminal" then
      vim.cmd("ToggleTerm")
    end

    local buf
    if vim.bo.filetype == "python" then
      buf = vim.api.nvim_get_current_buf()
    else
      buf = last_python_buf
    end

    if not buf or not vim.api.nvim_buf_is_valid(buf) then
      vim.notify("没有可运行的 Python 文件", vim.log.levels.WARN)
      return
    end

    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" or vim.fn.filereadable(file) == 0 then
      vim.notify("没有可运行的 Python 文件", vim.log.levels.WARN)
      return
    end

    if vim.bo[buf].modified then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent write")
      end)
    end

    local dir = vim.fn.fnamemodify(file, ":h")
    require("toggleterm").exec(
      "cd " .. vim.fn.shellescape(dir) .. " && python3 " .. vim.fn.shellescape(file),
      1,
      8,
      dir,
      "horizontal",
      "python",
      false
    )
  end

  vim.keymap.set({ "n", "t" }, "<F5>", run_python, {
    silent = true,
    desc = "运行上一次编辑的 Python 文件",
  })
  -- 插入模式下 F5: 先退出插入模式(run_python 会自动保存改动)再运行
  vim.keymap.set("i", "<F5>", function()
    vim.cmd("stopinsert")
    run_python()
  end, {
    silent = true,
    desc = "保存并运行 Python 文件",
  })
end

require("lazy").setup({
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,   -- 显示隐藏目录和文件(以 . 开头)
            hide_gitignore = false,  -- 显示被 .gitignore 忽略的文件
          },
        },
        window = {
          width = 28,
          mappings = {
              -- 绑定 gy 键，一键复制当前文件/目录的绝对路径到系统剪切板
              ["gy"] = function(state)
                local node = state.tree:get_node()
                local path = node:get_id() -- 获取绝对路径
                
                vim.fn.setreg("+", path)   -- 写入系统剪切板
                vim.notify("已复制路径: " .. path, vim.log.levels.INFO, { title = "Neo-tree" })
              end,
            },
        },
      })

      -- 快捷键设置：使用系统默认的 \ 键。按下 \ 键再快速按下 e 键触发; Ctrl+] 等效
      vim.keymap.set('n', '<Leader>e', ':Neotree toggle<CR>', { silent = true })
      vim.keymap.set({ 'n', 'i' }, '<C-]>', '<Cmd>Neotree toggle<CR>', { silent = true })
    end
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local builtin = require("telescope.builtin")
      -- \f 搜索文件  \g 搜索内容(grep)  \b 搜索缓冲区
      vim.keymap.set('n', '<Leader>f', builtin.find_files, {})
      vim.keymap.set('n', '<Leader>g', builtin.live_grep, {})
      vim.keymap.set('n', '<Leader>b', builtin.buffers, {})
    end
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = config_toggleterm,
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require('github-theme').setup({})
      vim.cmd('colorscheme github_light_default')
    end,
  }
})

-- 设置输入法
require("input_method")

-- Neovide 专用设置
if vim.g.neovide then

  -- 窗口边距
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_left = 0
  vim.g.neovide_padding_right = 0
end
