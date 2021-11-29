local mylib = {}

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

end

function mylib.spawn (o)
    
end

return mylib