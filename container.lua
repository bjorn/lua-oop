--
-- Container extends Object with the ability to include children in the class
-- definition by overriding the 'new' and subclass mechanisms. It also sets
-- a 'parent' property on the children that they can use to access their
-- parent.
--
-- This does make intantiation more heavy-weight so should not be used by
-- classes that don't need to have children.
--
-- CREATING A DERIVED CLASS
--
--      local FruitBasket = Container {
--          Apple {},
--          Apple {},
--          Apple {},
--      }
--
--      -- Create a fruit basket that contains three apples
--      local fruitBasket = FruitBasket:new()
--

local Object = require "object"

local Container = Object {
    -- A primitive container class is one that doesn't define any children
    -- (this a private member used for optimization)
    _primitive_ = true,

    -- This function is called when the whole object hierarchy defined by
    -- this class, its superclasses and its children has been created.
    creationComplete = function() end
}

--
-- Recursivelys intantiate children that have been defined as part of the
-- classes in the type hierarchy.
--
local function createChildren(class, instance)
    -- First create the children defined in the superclass
    local superclass = getmetatable(class)
    if not rawget(superclass, "_primitive_") then
        createChildren(superclass, instance)
    end

    -- Create children defined in this class
    for i=1,#class do
        local childClass = class[i]
        local child = childClass:new(nil, instance)
        local id = rawget(childClass, "id")

        -- Children can be iterated by index
        instance[#instance + 1] = child

        -- Or accessed by their id when one was specified
        if id then
            assert(type(id) == "string", "id must be a string!")
            assert(not rawget(instance, id), "duplicate id")
            instance[id] = child
        end
    end
end

--
-- It turns 'subclass' into a subclass of 'class', and prepares it to be
-- used as metatable for instances of 'subclass'.
--
-- This is a specialized version for 'Container' that sets the private member
-- '_primitive_' to indicate whether the class has any children.
--
local function derive(class, subclass)
    -- The class is reused as the metatable for subclasses and instances
    subclass.__index = subclass
    subclass.__call = derive
    subclass._primitive_ = rawget(class, "_primitive_") and #subclass == 0

    return setmetatable(subclass, class)
end

Container.__call = derive

--
-- Overrides Object.new
--
-- This is a specialized version of Object.new that will also instantiate
-- any children defined as part of the class definition (and the children
-- defined as part of any subclasses).
--
function Container:new(instance, parent)
    assert(rawget(self, "__call"), "Trying to instantiate an instance")

    instance = setmetatable(instance or {}, self)

    -- Make sure the parent can be accessed when init is called
    if parent then
        instance.parent = parent
    end

    instance:init()

    if not rawget(self, "_primitive_") then
        createChildren(self, instance)
        instance:creationComplete()
    end

    return instance
end

return Container
