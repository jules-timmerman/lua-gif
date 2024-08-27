--- Module to fetch GIFs from online
-- @module lua_gif
local M = {}

local https = require("ssl.https")
local cjson = require("cjson")
local url = require("socket.url")

local search_endpoint = "https://tenor.googleapis.com/v2/search?"
local API_KEY = nil

---Last "next" field, used to continue search
local last_next = ""
local last_params = {}

--- Enum like table for the various possible sizes
---@enum MediaFormat
M.MediaFormat = {
	PREVIEW = "preview",
	TINY = "tinygif",
	NORMAL = "gif",
	TINYMP4 = "tinymp4",
	MP4 = "mp4",
}

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
		local escaped_value = url.escape(value)
		local pairString = key .. "=" .. escaped_value
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

---Does a request at endpoint with parameters
---@param endpoint string
---@param params table<string, string|integer>
---@return table
local function request(endpoint, params)
	addAPIToTable(params)
	local paramString = buildParams(params)
	local url_str = endpoint .. paramString

	local res, code, headers, status = https.request(url_str)
	if code == 200 then
		return cjson.decode(res)
	else
		error(("Request didn’t work, error code : %d"):format(code))
	end
end

--- A media (GIF, MP4...) returned by the API
---@class MediaObject
---@field url string

---The result returned by the API from a search call
---@class Result
---@field content_description string
---@field media_formats table<MediaFormat, MediaObject>

---Searches GIFs
---@param term string The term to search
---@param sizes MediaFormat[] Formats requested
---@param limit? integer The number of searchs (default : 10)
---@return Result[]
function M.search(term, sizes, limit)
	-- Default of limit is 10
	limit = limit or 10

	-- Setup the parameters
	local params = { q = term, limit = limit }
	addMediaFilter(sizes, params)

	-- Do the request
	local response = request(search_endpoint, params)
	-- Save the parameters to allow continue
	last_next = response.next
	last_params = params
	-- Return the result
	return response.results
end

---Continue last search
---@param sizes? MediaFormat[] Formats requested (defaults to the same as before)
---@param limit? integer The numer of searchs (defaults to the same as before)
---@return Result[]
function M.nextResults(sizes, limit)
	local params = last_params
	if sizes ~= nil then
		addMediaFilter(sizes, params)
	end
	if limit ~= nil then
		params.limit = limit
	end
	params.pos = last_next

	local response = request(search_endpoint, params)
	last_next = response.next
	last_params = params
	return response.results
end

return M
