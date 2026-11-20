local ENGLISH = "xkb:us::eng"

-- 上次按下 Ctrl+Space 的时间戳, 用于防抖
local last_press = 0


-- 检查当前输入法: 已经是英文就什么都不做
-- 不是英文则用 ydotool 模拟 Ctrl+Space 切换输入法 (29=左Ctrl, 57=空格)
-- 注意: 一次窗口切换会连发多个事件(WinEnter/BufEnter 等), 而 Ctrl+Space 是
-- 切换键且 ibus 状态生效有延迟, 若短时间内连按两下会互相抵消(切过去又切回来),
-- 所以按下后 300ms 内的重复调用直接跳过
local function switch_to_english()
    if vim.uv.now() - last_press < 300 then
        return
    end

    local current = (vim.fn.system("ibus engine"):gsub("\n", ""))
    if current ~= ENGLISH then
        vim.fn.system("ydotool key 29:1 57:1 57:0 29:0")
        last_press = vim.uv.now()
    end
end


-- 打开 nvim / 切换窗口 / 离开插入模式 / 进入命令行模式(:)时检查输入法
vim.api.nvim_create_autocmd(
    { "VimEnter", "WinEnter", "BufEnter", "InsertLeave", "CmdlineEnter" },
    { callback = switch_to_english }
)
