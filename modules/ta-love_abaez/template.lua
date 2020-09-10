--- the template module to base all other modules from.
-- @author [Alejandro Baez](https://twitter.com/a_baez)
-- @module template

local M = {}

--- an initializer for the object.
-- @param extend extend the initializer with another table.
function M:new(extend)
  local extend = extend or {}
  setmetatable(extend, self)
  self.__index = self
  self.load(self)

  return extend
end

--- the prototype constructor.
-- @param example an example on how to use the constructor.
function M:load(example)
  self.example = example
end

--- forms the canvas of the object.
function M:draw()
end

--- motion of the object
-- @param dt see @{main| dt}.
function M:update(dt)
end

return M
