--[[ 
	This library simply adds the ability to have the setScene function called on your storyboard  before the transition. 
	setScene is called at the same time the createScene function is called.
    createScene is not called after the scene has been loaded for the first time.
--]]
 
local storyboard = require "storyboard"
 
-- get reference to the storyboard gotoScene function
local gofunc = storyboard.gotoScene
 
-- override the storyboard gotoScene event with our own conditions
--[[
local function go(name,trans,time)
        -- attempt to get the destination scene
        local scene = storyboard.getScene(name)
 
        -- if the destination scene exists then call its setup function
        if (scene) then
                scene:dispatchEvent( { name="setScene", target=scene } )
        end
 
        -- continue with normal storyboard.gotoScene
        gofunc(name,trans,time)
end
--]]
local function go(name, options)
        -- attempt to get the destination scene
        local scene = storyboard.getScene(name)
 
        -- if the destination scene exists then call its setup function
        if (scene) then
           scene:dispatchEvent( { name="setScene", target=scene, params=options.params } )
        end
 
        -- continue with normal storyboard.gotoScene
        gofunc( name, options )
end

storyboard.gotoScene = go