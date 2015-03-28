
function get_files()
    local res = {}
    while true do
        local line = vlc.readline()
        if not line then break end
        local download_url, filename = string.match(
            line, "<a[^>]+href='(/get/%d+)'[^>]+title[^>]+>(.-)</a>")

        if download_url and filename then
            vlc.msg.info(filename)
            vlc.msg.info(download_url)
            download_url = "http://ex.ua" .. vlc.strings.
                resolve_xml_special_chars(download_url)

            table.insert(res, {url=download_url, filename=filename})
        end
    end
    return res
end




function probe()
    -- ex.ua support only http
    if vlc.access ~= "http" then
        return false
    end
    return string.match(vlc.path, "ex.ua/%d+")
end


function parse()
    local files = get_files()
    local playlist = {}
    for _,file in ipairs(files) do
        table.insert(playlist, {path=file.url, name=file.filename})
    end
    return playlist
end
