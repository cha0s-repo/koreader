local InputContainer = require("ui/widget/container/inputcontainer")
local Event = require("ui/event")
local DEBUG = require("dbg")
local _ = require("gettext")
-- lfs

local ReaderTypeset = InputContainer:new{
	css_menu_title = _("Set render style"),
	css = nil,
	internal_css = true,
}

function ReaderTypeset:init()
	self.ui.menu:registerToMainMenu(self)
end

function ReaderTypeset:onReadSettings(config)
	self.css = config:readSetting("css")
	if self.css and self.css ~= "" then
		self.ui.document:setStyleSheet(self.css)
	else
		self.ui.document:setStyleSheet("")
		self.css = nil
	end

	self.embedded_css = config:readSetting("embedded_css")
	-- default to enable embedded css
	if self.embedded_css == nil then
		self.embedded_css = true
		self.ui.document:setEmbeddedStyleSheet(1)
	end
	if not self.embedded_css then
		self.ui.document:setEmbeddedStyleSheet(0)
	end

	self.floating_punctuation = config:readSetting("floating_punctuation")
	-- default to no floating punctuation
	if self.floating_punctuation == nil then
		self.floating_punctuation = 0
	end
	self.ui.document:setFloatingPunctuation(self.floating_punctuation)
end

function ReaderTypeset:onSaveSettings()
	self.ui.doc_settings:saveSetting("css", self.css)
	self.ui.doc_settings:saveSetting("embedded_css", self.embedded_css)
	self.ui.doc_settings:saveSetting("floating_punctuation", self.floating_punctuation)
end

function ReaderTypeset:onToggleEmbeddedStyleSheet(toggle)
	self:toggleEmbeddedStyleSheet(toggle)
	return true
end

function ReaderTypeset:genStyleSheetMenu()
	local file_list = {
		{
			text = _("clear all external styles"),
			callback = function()
				self:setStyleSheet(nil)
			end
		},
		{
			text = _("Auto"),
			callback = function()
				self:setStyleSheet(self.ui.document.default_css)
			end
		},
	}
	for f in lfs.dir("./data") do
		if lfs.attributes("./data/"..f, "mode") == "file" and string.match(f, "%.css$") then
			table.insert(file_list, {
				text = f,
				callback = function()
					self:setStyleSheet("./data/"..f)
				end
			})
		end
	end
	return file_list
end

function ReaderTypeset:setStyleSheet(new_css)
	if new_css ~= self.css then
		--DEBUG("setting css to ", new_css)
		self.css = new_css
		if new_css == nil then
			new_css = ""
		end
		self.ui.document:setStyleSheet(new_css)
		self.ui:handleEvent(Event:new("UpdatePos"))
	end
end

function ReaderTypeset:setEmbededStyleSheetOnly()
	if self.css ~= nil then
		-- clear applied css
		self.ui.document:setStyleSheet("")
		self.ui.document:setEmbeddedStyleSheet(1)
		self.css = nil
		self.ui:handleEvent(Event:new("UpdatePos"))
	end
end

function ReaderTypeset:toggleEmbeddedStyleSheet(toggle)
	if not toggle then
		self.embedded_css = false
		self:setStyleSheet(self.ui.document.default_css)
		self.ui.document:setEmbeddedStyleSheet(0)
	else
		self.embedded_css = true
		--self:setStyleSheet(self.ui.document.default_css)
		self.ui.document:setEmbeddedStyleSheet(1)
	end
	self.ui:handleEvent(Event:new("UpdatePos"))
end

function ReaderTypeset:toggleFloatingPunctuation()
	self.floating_punctuation = self.floating_punctuation == 0 and 1 or 0
	self.ui.document:setFloatingPunctuation(self.floating_punctuation)
	self.ui:handleEvent(Event:new("UpdatePos"))
end

function ReaderTypeset:addToMainMenu(tab_item_table)
	-- insert table to main reader menu
	table.insert(tab_item_table.typeset, {
		text = self.css_menu_title,
		sub_item_table = self:genStyleSheetMenu(),
	})
	table.insert(tab_item_table.typeset, {
		text_func = function() 
			return self.floating_punctuation == 1 and 
			_("Turn off floating punctuation") or 
			_("Turn on floating punctuation")
		end,
		callback = function () self:toggleFloatingPunctuation() end,
	})
end

return ReaderTypeset
