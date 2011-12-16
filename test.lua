local Object = require "object"
local Container = require "container"

local clock = os.clock

local Fruit = Object {
    weight = 0,
    color = "undefined",
}

function Fruit:eat()
    self.weight = 0
end

assert(rawget(getmetatable(Fruit), "__call") ~= nil, "Hmm")


-- An apple is a special kind of fruit
local Apple = Fruit {
    weight = 1,
    color = "green",
}

function Apple:eat()
    -- Most people don't eat the whole apple
    self.weight = self.weight / 2.0
    print("Ate apple")
end


-- A fruit basket that contains fruit
local FruitBasket = Object {}

function FruitBasket:init()
    self.contents = {}
end

function FruitBasket:add(fruit)
    self.contents[#self.contents + 1] = fruit
    print("Added fruit with weight", fruit.weight, "and color", fruit.color)
end

-- Eating the fruit basket means eating all the fruit it contains
function FruitBasket:eat()
    for k,v in pairs(self.contents) do
        v:eat()
    end
end

function FruitBasket:isEmpty()
    return next(self.contents) == nil
end

function FruitBasket:weight()
    local weight = 0
    for k,v in pairs(self.contents) do
        weight = weight + v.weight
    end
    return weight
end

assert(rawget(getmetatable(FruitBasket), "__call") ~= nil, "Hmm2")

local fruitBasket = FruitBasket:new()

for i=1,10 do
    local apple = Apple:new()
    fruitBasket:add(apple)
end

print("Basket weight is", fruitBasket:weight())
fruitBasket:eat()
print(fruitBasket:isEmpty() and "Basket empty" or "Basket not empty")
print("Basket weight is", fruitBasket:weight())

local fruit = Fruit {}
print("Fruit as Fruit", fruit:as(Fruit))
print("Fruit as Apple", fruit:as(Apple))

fruit = Apple {}
print("Apple as Object", fruit:as(Object))
print("Apple as Fruit", fruit:as(Fruit))
print("Apple as Apple", fruit:as(Apple))


local start


assert(Apple:new():as(Apple))

start = clock()
for i=1,1000000 do
    local fruit = Apple:new()
end
print("Apple creation time:", clock() - start)

Point = Object {
    x = 0,
    y = 0,
}

start = clock()
for i=1,1000000 do
    local point = Point:new { x = 10, y = 20 }
end
print("Point creation time:", clock() - start)

start = clock()
for i=1,1000000 do
    local point = { x = 10, y = 20 }
end
print("Point creation time (raw):", clock() - start)


fruit = Fruit:new()
local start = clock()
for i=1,1000000 do
    fruit:eat()
end

print("Calling member function time:", clock() - start)

collectgarbage("collect")
print("Memory (base):", collectgarbage("count"))

local points = {}
for i=1,10000 do
    points[i] = Point:new { x = 10, y = 20 }
end

collectgarbage("collect")
print("Memory (points):", collectgarbage("count"))

points = {}
for i=1,10000 do
    points[i] = { x = 10, y = 20 }
end

collectgarbage("collect")
print("Memory (raw points):", collectgarbage("count"))


-- A polygon is a container that contains points
local Polygon = Container {}

function Polygon:length()
    return #self
end

function Polygon:append(point)
    self[#self + 1] = point
end

-- A square is a polygon with 4 nodes
local Square = Polygon {
    Point { x = 0, y = 0 },
    Point { x = 0, y = 10 },
    Point { x = 10, y = 10 },
    Point { x = 10, y = 0 },
}

-- Create a square polygon and print its length
local square = Square:new()
print("A square polygon has length: " .. square:length())
