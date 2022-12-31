local M = {}

M.version = '0.2.0'

local function is_continuous_clipboard_sync_enabled()
    return vim.o.clipboard ~= nil
        and vim.o.clipboard ~= ''
end

local function schedule_disable_of_continuous_clipboard_sync_on_focus_change()
    vim.api.nvim_create_autocmd({
        'FocusGained',
        'FocusLost',
    }, {
        once = true,
        pattern = '*',
        callback = function()
            vim.o.clipboard = nil
        end,
    })
end

local function copy_register(from, to)
		vim.fn.setreg(
				to,
				vim.fn.getreginfo(from)
		)
end

local function schedule_clipboard_sync_on_focus_change()
    local deferred_clipboard_sync_group = vim.api.nvim_create_augroup(
        'DeferredClipboardSync',
        { clear = true }
    )

    vim.api.nvim_create_autocmd({
        'FocusLost',
        'VimLeavePre'
    }, {
        group = deferred_clipboard_sync_group,
        pattern = '*',
        callback = function()
            copy_register('"', '+')
        end
    })

    vim.api.nvim_create_autocmd('FocusGained', {
        group = deferred_clipboard_sync_group,
        pattern = '*',
        callback = function()
            copy_register('+', '"')
        end
    })
end

function M.setup()
    schedule_clipboard_sync_on_focus_change()
		copy_register('+', '"')

    if is_continuous_clipboard_sync_enabled() then
        schedule_disable_of_continuous_clipboard_sync_on_focus_change()
    end
end

return M
