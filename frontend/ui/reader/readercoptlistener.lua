local EventListener = require("ui/widget/eventlistener")
local Event = require("ui/event")

local ReaderCoptListener = EventListener:new{}

function ReaderCoptListener:onReadSettings(config)
	local embedded_css = config:readSetting("copt_embedded_css")
	local toggle_embedded_css = embedded_css == 0 and false or true
	table.insert(self.ui.postInitCallback, function()
        self.ui:handleEvent(Event:new("ToggleEmbeddedStyleSheet", toggle_embedded_css))
    end)
	
	local view_mode = config:readSetting("copt_view_mode")
	if view_mode == 0 then
		table.insert(self.ui.postInitCallback, function()
	        self.ui:handleEvent(Event:new("SetViewMode", "page"))
	    end)
	elseif view_mode == 1 then
		table.insert(self.ui.postInitCallback, function()
	        self.ui:handleEvent(Event:new("SetViewMode", "scroll"))
	    end)
	end
	
	local copt_margins = config:readSetting("copt_page_margins")
	if copt_margins == nil then
		copt_margins = DCREREADER_CONFIG_MARGIN_SIZES_MEDIUM
	end
	table.insert(self.ui.postInitCallback, function()
	    self.ui:handleEvent(Event:new("SetPageMargins", copt_margins))
	end)
end

return ReaderCoptListener
