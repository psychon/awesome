---------------------------------------------------------------------------
--- Screen module for awful
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release @AWESOME_VERSION@
-- @module awful.screen
---------------------------------------------------------------------------

-- Grab environment we need
local capi =
{
    mouse = mouse,
    screen = screen,
    client = client
}
local util = require("awful.util")

-- we use require("awful.client") inside functions to prevent circular dependencies.
local client

local screen = {}

local data = {}
data.padding = {}

screen.mouse_per_screen = {}

---
-- Return Xinerama screen number corresponding to the given (pixel) coordinates.
-- The number returned can be used as an index into the global
-- `screen` table/object.
-- @param x The x coordinate
-- @param y The y coordinate
-- @param[opt] default The default return value. If unspecified, 1 is returned.
function screen.getbycoord(x, y, default)
    for i = 1, capi.screen:count() do
        local geometry = capi.screen[i].geometry
        if((x < 0 or (x >= geometry.x and x < geometry.x + geometry.width))
           and (y < 0 or (y >= geometry.y and y < geometry.y + geometry.height))) then
            return i
        end
    end
    -- No caller expects a nil result here, so just make something up
    if default == nil then return 1 end
    return default
end

--- Give the focus to a screen, and move pointer to last known position on this
-- screen, or keep position relative to the current focused screen
-- @param _screen Screen number (defaults / falls back to mouse.screen).
function screen.focus(_screen)
    client = client or require("awful.client")
    if _screen > capi.screen.count() then _screen = screen.focused() end

    -- screen and pos for current screen
    local s = capi.mouse.screen
    local pos

    if not screen.mouse_per_screen[_screen] then
        -- This is the first time we enter this screen,
        -- keep relative mouse position on the new screen
        pos = capi.mouse.coords()
        local relx = (pos.x - capi.screen[s].geometry.x) / capi.screen[s].geometry.width
        local rely = (pos.y - capi.screen[s].geometry.y) / capi.screen[s].geometry.height

        pos.x = capi.screen[_screen].geometry.x + relx * capi.screen[_screen].geometry.width
        pos.y = capi.screen[_screen].geometry.y + rely * capi.screen[_screen].geometry.height
    else
        -- restore mouse position
        pos = screen.mouse_per_screen[_screen]
    end

    -- save pointer position of current screen
    screen.mouse_per_screen[s] = capi.mouse.coords()

   -- move cursor without triggering signals mouse::enter and mouse::leave
    capi.mouse.coords(pos, true)

    local c = client.focus.history.get(_screen, 0)
    if c then
        c:emit_signal("request::activate", "screen.focus", {raise=false})
    end
end

--- Give the focus to a screen, and move pointer to last known position on this
-- screen, or keep position relative to the current focused screen
-- @param dir The direction, can be either "up", "down", "left" or "right".
-- @param _screen Screen number.
function screen.focus_bydirection(dir, _screen)
    local sel = _screen or screen.focused()
    if sel then
        local geomtbl = {}
        for s = 1, capi.screen.count() do
            geomtbl[s] = capi.screen[s].geometry
        end
        local target = util.get_rectangle_in_direction(dir, geomtbl, capi.screen[sel].geometry)
        if target then
            return screen.focus(target)
        end
    end
end

--- Give the focus to a screen, and move pointer to last known position on this
-- screen, or keep position relative to the current focused screen
-- @param i Value to add to the current focused screen index. 1 will focus next
-- screen, -1 would focus the previous one.
function screen.focus_relative(i)
    return screen.focus(util.cycle(capi.screen.count(), screen.focused() + i))
end

--- Get or set the screen padding.
-- @param _screen The screen object to change the padding on
-- @param padding The padding, an table with 'top', 'left', 'right' and/or
-- 'bottom'. Can be nil if you only want to retrieve padding
function screen.padding(_screen, padding)
    if padding then
        data.padding[_screen] = padding
        _screen:emit_signal("padding")
    end
    return data.padding[_screen]
end

--- Get the focused screen.
-- This can be replaced in a user's config.
-- @treturn integer
function screen.focused()
    return capi.mouse.screen
end

capi.screen.add_signal("padding")

return screen

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
