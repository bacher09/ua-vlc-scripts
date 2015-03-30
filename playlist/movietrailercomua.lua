
function probe()
    -- movietrailer.com.ua support only http
    if vlc.access ~= "http" then
        return false
    end
    return string.match(vlc.path, "movietrailer%.com%.ua/item/")
end


function parse()
    local item = {}

    while true do
        local line = vlc.readline()
        if not line then break end
        local download_url = string.match(
            line, "url:%s+'(/trailers/%w+%.mp4)'")

        local art = string.match(
            line, "snapshot: '(http://.-%.jpg)'")

        local title = string.match(
            line, "<h1%s+class=\"b%-item__title\"%s*>([^<]+)</h1>")

        if download_url then
            item.path = "http://movietrailer.com.ua"..download_url
        end

        if art then
            item.arturl = art
        end

        if title then
            item.name = title
        end
    end
    return {item}
end
