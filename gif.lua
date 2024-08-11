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

return M
