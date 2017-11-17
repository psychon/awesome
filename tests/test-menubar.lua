-- Test the menubar

local runner = require("_runner")
local menubar = require("menubar")

local menubar_refreshed = false
local orig_refresh = menubar.refresh
function menubar.refresh(...)
    menubar_refreshed = true
    orig_refresh(...)
end

-- Make sure no error messages for non-existing directories are printed. If the
-- word "error" appears in our output, the test is considered to have failed.
do
    local gdebug = require("gears.debug")
    local orig_warning = gdebug.print_warning
    function gdebug.print_warning(msg)
        msg = tostring(msg)
        if (not msg:match("/dev/null/.local/share/applications")) and
                (not msg:match("No such file or directory")) then
            orig_warning(msg)
        end
    end
end

runner.run_steps {
    function(count)
        -- Just show the menubar and hide it.
        -- TODO: Write a proper test. But for the mean time this is better than
        -- nothing (and tells us when errors are thrown).

        if count == 1 then
            menubar.show()
        end

        -- Test that the async population of the menubar is done
        if menubar_refreshed then
            menubar.hide()
            awesome.sync()
            return true
        end
    end,

    function()
        return true
    end
}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
