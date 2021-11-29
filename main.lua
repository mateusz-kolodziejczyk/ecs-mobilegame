-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- Imports
local rng = require("rng")
local colors = require("colorsRGB")
local mylib = require("mylib")
local Button = require("Button")
local db = require("db")
local tiny = require("tiny")
-- Identifiers

local entities = {}
local world = tiny.world()

-- Display Groups
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local background = display.newImageRect(backGroup,"./assets/images/background.png" ,1136,640)

background.x = display.contentCenterX
background.y = display.contentCenterY

display.setStatusBar(display.HiddenStatusBar)


-- Coin graphics
local coinLeft = display.newImageRect(uiGroup,"./assets/images/coin.png",30, 30)
coinLeft.x = 0
coinLeft.y = 30

local coinLeftText = display.newText(uiGroup, "0", 100, 200, "./assets/fonts/Bangers.ttf")
coinLeftText:setFillColor(colors.RGB("black"))
coinLeftText.anchorX = 0
coinLeftText.x = coinLeft.x + coinLeft.width/2
coinLeftText.y = coinLeft.y


local coinRight = display.newImageRect(uiGroup,"./assets/images/coin.png",30, 30)

coinRight.x = display.contentWidth
coinRight.y = 30

local coinRightText = display.newText(uiGroup, "0", 100, 200, "./assets/fonts/Bangers.ttf")

coinRightText.anchorX = display.contentWidth
coinRightText:setFillColor(colors.RGB("black"))
coinRightText.x = coinRight.x - coinLeft.width/2
coinRightText.y = coinRight.y

local bases = {}
bases['left'] = mylib.base {left=true, coinsText=coinLeftText}
bases['right'] = mylib.base {right=true, coinsText=coinRightText}

local function spawn(o)
    local base = bases[mylib.team(o)]
    if base.coins < db[o.name].cost then return end

    print("spawn "..o.name)
    base.coins = base.coins - db[o.name].cost
    local entity = mylib.spawn(o)
    entity.x = base.x - rng.random(-10, 10)
    entity.y = base.y + rng.random(-100,100)
    table.insert(entities, entity)
    world:addEntity(entity)
end
local histolyticaButton = Button:new{ group = uiGroup, name = "histolytica", 
    text=db["histolytica"].cost,
    x=display.contentCenterX -150, y=display.contentHeight-40,
    onEvent = function() spawn{name="histolytica", left=true}end
}

local fowleriButton = Button:new{ group = uiGroup, name = "fowleri", 
    text=db["fowleri"].cost,
    x=display.contentCenterX, y=display.contentHeight-40,
    onEvent = function() spawn{name="fowleri", left=true} end
}

local proteusButton = Button:new{ group = uiGroup, name = "proteus", 
    text=db["proteus"].cost,
    x=display.contentCenterX+ 150, y=display.contentHeight-40,
    onEvent = function() spawn{name="proteus", left=true} end
}

-- entiy component behaviours

table.insert(entities, bases['left'])
table.insert(entities, bases['right'])
world:addEntity(bases['left'])
world:addEntity(bases['right'])

local gatherResourcesSystem = tiny.processingSystem()
gatherResourcesSystem.filter = tiny.requireAll("base")
function gatherResourcesSystem:process(e, dt)
    e.lastCoinDrop = e.lastCoinDrop + dt
    --print("At base " .. mylib.team(e) .. " at time " .. e.lastCoinDrop)
    if e.lastCoinDrop > db[mylib.team(e)].skill then
        e.lastCoinDrop = 0
        e.coins = e.coins + 1
        print("At base " .. mylib.team(e) .. " coins: " .. e.coins)
    end
    e.coinsText.text = e.coins 
end

world:addSystem(gatherResourcesSystem)


-- Movement systtem amoeba 
local amoebaMovementSystem = tiny.processingSystem()
amoebaMovementSystem.filter = tiny.requireAny("histolytica", "fowleri", "proteus")
function amoebaMovementSystem:process(e, dt)
    -- Find closest enemy entity
    -- Update direction
    -- Update position
    e.x = e.x + e.dx
    e.y = e.y + e.dy
end
world:addSystem(amoebaMovementSystem)

-- game loop 
world:refresh()

local function gameLoop()
    world:update(1)
end
local gameLoopTimer = timer.performWithDelay(10, gameLoop,0)
