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
    end
    e.coinsText.text = e.coins 
end

world:addSystem(gatherResourcesSystem)


-- Movement systtem amoeba 
local amoebaMovementSystem = tiny.processingSystem()
amoebaMovementSystem.filter = tiny.requireAny("fowleri", "proteus", "histolytica")
function amoebaMovementSystem:process(entity, dt)
    -- Find closest enemy entity
    local closestEnemy
    local minDistSq = math.huge
    for _, other in pairs(entities) do 
        if mylib.enemy(entity) == mylib.team(other) then
            local distSq = mylib.distanceSq(entity, other)
            if distSq <  minDistSq then
                closestEnemy = other
                minDistSq = distSq
            end
        end
    end
    -- Update directio
    local dist = math.sqrt(minDistSq)
    if dist < entity.size/2 then return end

    local targetAngle = mylib.safe_tan2(closestEnemy.y-entity.y, 
    closestEnemy.x-entity.x)

    entity.image.rotation = 180/math.pi * targetAngle

    local speed=db[entity.name].speed
    entity.dx = speed*math.cos(targetAngle)
    entity.dy = speed*math.sin(targetAngle)

    --if dist < entity.size
    -- Update position
    entity.x = entity.x + entity.dx
    entity.y = entity.y + entity.dy
end
world:addSystem(amoebaMovementSystem)

-- Healtealthsystem base and amoeba
local healthSystem = tiny.processingSystem()
healthSystem.filter = tiny.requireAny("base", "histolytica", "proteus", "fowleri")
function healthSystem:process(entity, _)
    if entity.health<0 then
        entity.health = 0
        entity.dead = true
    end
    local relHealth = entity.health / db[entity.name].health
    entity.healthBar.width = relHealth * entity.size
end
world:addSystem(healthSystem)

-- MeleeSystem base and amoeba
local meleeSystem = tiny.processingSystem()
meleeSystem.filter = tiny.requireAny("base", "histolytica", "proteus", "fowleri")
function meleeSystem:process(entity, dt)
    for _, other in pairs(entities) do
        if mylib.enemy(entity) == mylib.team(other) then
            local dist = mylib.distance(entity,other)
            if dist <= entity.size/2 + other.size/2 then
                entity.health = (entity.health - db[other.name].attack / db[entity.name].defense)
                other.health = (other.health - db[entity.name].attack / db[other.name].defense)
            end
        end
    end
end
world:addSystem(meleeSystem)

-- Ai system
local aiSystem = tiny.processingSystem()
aiSystem.filter = tiny.requireAll("base", "right")
function aiSystem:process(entity, _)
        local amoeba = entity.nextAmoeba
        if entity.coins>=db[amoeba].cost then
            spawn {name=amoeba, left=entity.left, right=entity.right}
        end
end
world:addSystem(aiSystem)
-- game loop 
world:refresh()

local function gameLoop()
    world:update(1)
end
local gameLoopTimer = timer.performWithDelay(10, gameLoop,0)
print(db[proteus])