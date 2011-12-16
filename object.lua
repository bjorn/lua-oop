--
-- Object is the base class of anything that follows this OOP mechanism.
-- Usage example:
--
--
-- CREATING A DERIVED CLASS
--
--      local Human = Object:subclass {
--          name = "Anonymous",
--          weight = 0,
--      }
--
--      function Human:say(text)
--          print(self.name .. " says: " .. text)
--      end
--
--
-- INSTANTIATING AN OBJECT
--
--      local jim = Human {
--          name = "Jim Jimmalot"
--          weight = "85"
--      }
--
--      jim:say("Hi!")
--

--
-- Default constructor, called when class is used as a function.
-- It turns 'instance' into an instance of 'class'.
--
local function construct(class, instance)
    assert(rawget(class, "__call"), "Trying to intantiate an instance")

    setmetatable(instance, class)
    instance:init()
    return instance
end

--
-- It turns 'subclass' into a subclass of 'class', and prepares it to be
-- used as metatable for instances of 'subclass'.
--
local function subclass(class, subclass)
    -- The class is reused as the metatable for subclasses and instances
    subclass.__index = subclass
    subclass.__call = construct

    return setmetatable(subclass, class)
end

--
-- Bootstrap the first class into the hierarchy
--
local Object = subclass({
    -- Report an error when trying to access a member that doesn't exist
    __index = function(table, key)
        error("No such member: " .. tostring(key))
    end,
    __call = construct,
}, {})

Object.init = function() end
Object.subclass = subclass

--
-- Returns a constructor for this class. This saves some overhead compared to
-- relying on the metatable, and can be used for classes that are frequently
-- instantiated.
--
-- A module can only return the constructor, in which case the class can no
-- longer be subclassed and members are not accessible without creating an
-- instance.
--
function Object:constructor()
    local constructor = rawget(self, "_constructor_")

    if not constructor then
        assert(rawget(self, "__call"), "Instances can't have constructors")

        local init = self.init

        -- Avoid calling init when it's the empty default
        if init == Object.init then
            init = nil
        end

        constructor = function(instance)
            setmetatable(instance, self)
            if init then
                init(instance)
            end
            return instance
        end

        self._constructor_ = constructor
    end

    return constructor
end

--
-- Returns this object when it is an instance of the given class, and nil
-- otherwise.
--
function Object:as(class)
    local meta = getmetatable(self)

    if type(class) == "table" then
        while meta do
            if meta == class then
                return self
            end
            meta = getmetatable(meta)
        end
    elseif type(class) == "function" then
        -- Assuming contructor function, so class can't be a subclass
        if rawget(meta, "_constructor_") == class then
            return self
        end
    end

    return nil
end

--
-- Convenience function to log a message from an instance.
--
function Object:log(...)
    print(tostring(self) .. ":", ...)
end

return Object
