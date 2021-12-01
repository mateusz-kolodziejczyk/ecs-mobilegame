local mylib = {}
local db = require("db")
local colors = require("colorsRGB")
-----------------------------------------------------------------------------------------
--
-- Utility functions
--
-----------------------------------------------------------------------------------------
function mylib.team(o)
    assert(o.left or o.right, "Object should have either 'left' or 'right' property")
    return o.left and "left" or "right"
end

function mylib.enemy(o)
    assert(o.left or o.right, "Object should have either 'left' or 'right' property")
    return o.left and "right" or "left"
end

function mylib.distanceSq(a,b)
    return (a.x-b.x)^2 + (a.y-b.y)^2
end

function mylib.distance(a,b)
    return math.sqrt( mylib.distanceSq(a,b) )
end

function mylib.safe_tan2(y,x)
    local angle = math.atan2(y,x)
    if angle< 0 then 
        angle = angle + 2*math.pi
    end
    return angle
end

-----------------------------------------------------------------------------------------
--
-- Game Entities
--
-----------------------------------------------------------------------------------------

function mylib.base (o)
    local group = display.newGroup()
    group.x = o.x or (0 and o.left or display.contentWidth)
    group.y = o.y or display.contentCenterY
    local team = mylib.team(o)
    local filename = "assets/images/base_" .. team .. "_defence.png"
    print(filename)
    local size = db.base.size
    local image = display.newImageRect(filename, size, size)
    print(image)
    group:insert(image)

    group.coins = 150
    group.lastCoinDrop = 0
    group.coinsText = o.coinsText
    group.nextAmoeba = "histolytica"
    group.size = size
    group.image = image
    group.name = 'base' -- used for debugging
    group.base = true   -- used by entity

    group.health = db.base.health

    group.healthBar = display.newRect(group, 0, -size/2, size, 5)
    group.healthBar.strokeWidth = 1
    group.healthBar:setFillColor(0,1,0)
    group.healthBar:setStrokeColor(colors.RGB("white"))

    group[team] = true
    return group
end

function mylib.spawn (o)
    local group = display.newGroup()
    group.x = o.x or display.contentCenterX
    group.y = o.y or display.contentCenterY

    local team = mylib.team(o)
    group.dx = team == "left" and 1 or -1
    group.dy = 0

    local size = db[o.name].size

    local filename = "assets/images/" .. o.name .. "_" .. team .. ".png"
    local image = display.newImageRect(filename, db[o.name].size, db[o.name].size)
    group:insert(image)

    group.name = o.name -- debugging  
    group[o.name] = true -- entity
    group[team] = true
    group.image = image
    group.size = size
    group.health = db[o.name].health

    group.healthBar = display.newRect(group, 0, -size/2, size, 5)
    group.healthBar.strokeWidth = 1
    group.healthBar:setFillColor(0,1,0)
    group.healthBar:setStrokeColor(colors.RGB("white"))

    group.size = db[o.name].size
    return group
end

return mylib