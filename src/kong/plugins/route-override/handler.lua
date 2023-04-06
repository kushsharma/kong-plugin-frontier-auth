local plugin = {
    PRIORITY = 1000,
    VERSION = "0.1.0"
}
local ngx = ngx
local utils = require "kong.plugins.route-override.utils"

-- iterate over each captured param and replace it with the value actually
-- received in request
function resolveUrlParams(requestParams, url)
    for paramValue in requestParams do
        -- extract uri captures
        -- https://docs.konghq.com/gateway/latest/how-kong-works/routing-traffic/#capturing-groups
        -- for e.g. "/version/(?<version>\d+)/users/(?<user>\S+)" for "/version/1/users/john"
        -- router_matches.uri_captures is: { "1", "john", version = "1", user = "john" }
        local requestParamValue = ngx.ctx.router_matches.uri_captures[paramValue]

        if type(requestParamValue) == 'string' then
            -- handle escape characters with %
            requestParamValue = requestParamValue:gsub("%%", "%%%%")
        end

        -- replace all <params> with the actual uri captures
        url = url:gsub("<" .. paramValue .. ">", requestParamValue)
    end
    return url
end

-- extracts all parameter names from a URL by returning an iterator
-- that matches any substring surrounded by < and >.
function getRequestUrlParams(url)
    return string.gmatch(url, "<(.-)>")
end

function plugin:access(config)
    if config.query_string ~= nil then
        local args = ngx.req.get_uri_args()
        for k, queryString in ipairs(config.query_string) do
            local splitted = utils.split(queryString, '=')
            local key, value = splitted[1], splitted[2]
            local queryParams = getRequestUrlParams(value)
            local resolvedParams = resolveUrlParams(queryParams, value)
            args[key] = resolvedParams
        end
        ngx.req.set_uri_args(args)
    end

    -- build dynamic url with params if needed
    local requestParams = getRequestUrlParams(config.url)
    local url = resolveUrlParams(requestParams, config.url)

    -- if service `path` already set, just prepend
    local service_path = ngx.ctx.service.path or ""
    if service_path ~= "" then
        url = service_path .. url
    end

    ngx.var.upstream_uri = url
end

return plugin
