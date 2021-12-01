
local db = {
    histolytica = {size=30, 
            cost=10, 
            speed=4, 
            radius=15,
            health=1000,
            attack=10,
            defense=1},
    fowleri = {size=30, 
            cost=25, 
            speed=2, 
            radius=15,
            health=5000,
            attack=5,
            defense=3},
    proteus = {size=40, 
            cost=50, 
            speed=1, 
            radius=20,
            health=20000,
            attack=1,
            defense=5},
}

db.base = { health=30000, attack=3, defense=3, size = 30}
db.left = { skill=25}
db.right = { skill=25}


return db