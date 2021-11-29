-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local rng = require("rng")
local colors = require("colorsRGB")
local mylib = require("mylib")
local Button = require("Button")

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local background = display.newImageRect(backGroup,"./assets/images/background.png" ,1136,640)

background.x = display.contentCenterX
background.y = display.contentCenterY

display.setStatusBar(display.HiddenStatusBar)

local game = {
    histolytica = {cost=10, speed=10, radius=15},
    fowleri = {cost=25, speed=5, radius=15},
    proteus = {cost=50, speed=2, radius=20},

}

local coinLeft = display.newImageRect(uiGroup,"./assets/images/coin.png",30, 30)
coinLeft.x = 0
coinLeft.y = 30

local coinLeftText = display.newText(uiGroup, "0", 100, 200, "./assets/fonts/Bangers.ttf")
coinLeftText:setFillColor(colors.RGB("black"))
coinLeftText.anchorX = 0
coinLeftText.x = coinLeft.x
coinLeftText.y = coinLeft.y


local coinRight = display.newImageRect(uiGroup,"./assets/images/coin.png",30, 30)

coinRight.x = display.contentWidth
coinRight.y = 30

local coinRightText = display.newText(uiGroup, "0", 100, 200, "./assets/fonts/Bangers.ttf")

coinRightText.anchorX = display.contentWidth
coinRightText:setFillColor(colors.RGB("black"))
coinRightText.x = coinRight.x
coinRightText.y = coinRight.y

local histolyticaButton = Button:new{ group = uiGroup, name = "histolytica", 
    text=game["histolytica"].cost,
    x=display.contentCenterX -150, y=display.contentHeight-40,
    onEvent = function() print("histolytica") end
}

local fowleriButton = Button:new{ group = uiGroup, name = "fowleri", 
    text=game["fowleri"].cost,
    x=display.contentCenterX, y=display.contentHeight-40,
    onEvent = function() print("fowleri") end
}

local proteusButton = Button:new{ group = uiGroup, name = "proteus", 
    text=game["proteus"].cost,
    x=display.contentCenterX+ 150, y=display.contentHeight-40,
    onEvent = function() print("proteus") end
}