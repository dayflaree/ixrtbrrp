local PLUGIN = PLUGIN

PLUGIN.name = "Suppression"
PLUGIN.description = "Adds suppression mechanics to the server."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2024 Riggs Mackay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.config.Add("suppressionViewPunch", true, "Whether or not to apply view punch suppression effects.", nil, {
    category = "Suppression"
})

ix.config.Add("suppressionViewPunchIntensity", 5, "The intensity of the view punch suppression effects.", nil, {
    category = "Suppression",
    data = {min = 0, max = 5, decimals = 1}
})

ix.config.Add("suppressionBuildupSpeed", 1, "The speed at which suppression effects build up.", nil, {
    category = "Suppression",
    data = {min = 0, max = 5, decimals = 1}
})

ix.config.Add("suppressionSharpen", true, "Whether or not to apply sharpen suppression effects.", nil, {
    category = "Suppression"
})

ix.config.Add("suppressionSharpenIntensity", 1, "The intensity of the sharpen suppression effects.", nil, {
    category = "Suppression",
    data = {min = 0, max = 5, decimals = 1}
})

ix.config.Add("suppressionBloom", true, "Whether or not to apply bloom suppression effects.", nil, {
    category = "Suppression"
})

ix.config.Add("suppressionBlur", false, "Whether or not to apply blur suppression effects.", nil, {
    category = "Suppression"
})

ix.config.Add("suppressionBlurStyle", true, "The style of the blur suppression effects.", nil, {
    category = "Suppression"
})

ix.config.Add("suppressionBlurIntensity", 1, "The intensity of the blur suppression effects.", nil, {
    category = "Suppression",
    data = {min = 0, max = 5, decimals = 1}
})

ix.config.Add("suppressionBloomIntensity", 1, "The intensity of the bloom suppression effects.", nil, {
    category = "Suppression",
    data = {min = 0, max = 5, decimals = 1}
})

ix.config.Add("suppressionEnabled", true, "Whether or not suppression effects are enabled.", nil, {
    category = "Suppression"
})

ix.config.Add("suppressionGaspEnabled", true, "Whether or not to play gasp sounds when suppression effects are applied.", nil, {
    category = "Suppression"
})

ix.config.Add("suppressionEnableVehicle", true, "Whether or not to apply suppression effects when in a vehicle.", nil, {
    category = "Suppression"
})

ix.config.Add("suppressionSelfSuppress", false, "Whether or not to suppress the player when they shoot.", nil, {
    category = "Suppression"
})

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")