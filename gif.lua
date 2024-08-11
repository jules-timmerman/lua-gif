local M = {}

local https = require("ssl.https")

local search_endpoint = "https://tenor.googleapis.com/v2/search?"
local API_KEY = nil

---Sets the global API key
---Should be used before any other calls
---@param apiKey string
function M.setAPIKey(apiKey)
	API_KEY = apiKey
end

-- TODO : Might need to sanitize at some point
---Create URL parameters from table
---@param t table<string,integer | string>
---@return string param Parameters as a single query string
local function buildParams(t)
	local s = ""
	for key, value in pairs(t) do
		local pairString = key .. "=" .. value
		s = s .. pairString .. "&"
	end
	return s
end

---Add the API Key to the request parameters
---@param t table<string,string|integer>
local function addAPIToTable(t)
	if API_KEY then
		t["key"] = API_KEY
	else
		error("API_KEY not set, please use setAPIKey before")
	end
end

---Add the media filter argument to parameters
---@param types (string | table<string,string>) String or list of media types to filter
---@param params table<string, string|integer>
local function addMediaFilter(types, params)
	if type(types) == "string" then
		params["media_filter"] = types
	elseif type(types) == "table" then
		local s = ""
		for _, value in ipairs(types) do
			s = s .. value .. ","
		end
		s = s:sub(1, -2)
		params["media_filter"] = s
	else
		error("Media filter not a string or table")
	end
end

return M
