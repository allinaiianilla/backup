local ENGLISH = "xkb:us::eng"


local function get_input_method()
    return vim.fn.system("ibus engine"):gsub("\n", "")
end


local function switch_to_english()
    local current = get_input_method()

    if current ~= ENGLISH then
        vim.fn.system(
            "ydotool key 29:1 57:1 57:0 29:0"
        )
    end
end


vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        switch_to_english()
    end,
})


vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        switch_to_english()
    end,
})
