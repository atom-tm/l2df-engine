gamera		= require "libs.external.gamera"
json 		= require "libs.external.json"
---------------------------------------------
settings 	= require "libs.settings"
rooms 		= require "libs.rooms"
loc 		= require "libs.localization"
data 		= require "libs.data"

sounds 		= require "libs.sounds"
image 		= require "libs.images"
resourses	= require "libs.resourses"
font 		= require "libs.fonts"

helper 		= require "libs.helper"
get 		= require "libs.get"
func 		= require "libs.functions"

battle		= require "libs.battle"
---------------------------------------------
camera = nil
locale = nil
---------------------------------------------
settings:initialize()
settings:load()
rooms:initialize()