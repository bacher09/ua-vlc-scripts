
function get_id (url)
    return string.match(url, "/([^-/]+)[%w-]+\.html")
end

function get_canonical()
    local url
    local line
    while true do
        line = vlc.readline()
        if not line then break end
        if string.match(line, "rel=\"canonical\"") then
            _,_,url= string.find(line, "href=\"(.-)\"" )
            url = vlc.strings.resolve_xml_special_chars( url )
            return url
        end
    end
end

function find_many(data, pattern)
    local res = {}
    local i = 0
    while true do
        _,i,block = string.find(data, pattern, i+1)
        if not i then break end 
        table.insert(res, block)
    end
    return res
end

function query_folder(url, id, folder_id)
    local sd = vlc.stream(url.."?ajax&id="..id.."&folder="..folder_id)
    if not sd then
        return nil
    else
        return sd:read(65535)
    end
end

function parse_folders(result)
    local res_obj = {}
    if not result then return nil end
    local folder_blocks = find_many(result, "<li class=\"folder[^<]->(.-)</li>")
    for k,v in pairs(folder_blocks) do
        folder_obj = {}
        folder_id, folder_name = string.match(v, "<a href=\"#\".-rel=\"{parent_id: '?([0-9]*)'?.-}\">(.-)</a>")
        if folder_id and folder_name then
            clean_name = string.match(folder_name, "<b>(.-)</b>")
            if clean_name then
                folder_name = clean_name
            end
        end
        folder_obj.id = folder_id
        folder_obj.name = folder_name
        table.insert(res_obj, folder_obj)
    end
    return res_obj
end

function parse_medias(result)
    local res_obj = {}
    if not result then return nil end
    local media_blocks = find_many(result, "<li class=\"b--file--new[^<]->(.-)</li>")
    for k,v in pairs(media_blocks) do
        vlc.msg.info("begin media")
        local media = {}
        _,_,video_quality = string.find(v, "<span class=\"video--qulaity.-\">([^<]+)</span>")
        _,_,filename = string.find(v, "<span[^>]*class=\".-filename--text\"[^>]*>([^<]+)</span>")
         _,_,series = string.find(v, "<span[^>]*class=\".-filename--series--num\"[^>]*>([^<]+)</span>")
        _,_,file_url = string.find(v, "<a.-href=\"(/get/.-)\"")
        media.video_quality = video_quality
        media.filename = filename
        media.series = series
        media.url = "http://fs.to" .. file_url
        table.insert(res_obj, media)
        vlc.msg.info("end media")
    end
    return res_obj
end


function update_medias(medias, new_medias, folder)
    vlc.msg.info("function update_medias")
    for k,v in pairs(new_medias) do
        vlc.msg.info("begin update loop")
        if not v.folder then
            v.folders = {}
        end
        table.insert(v.folders, folder)
        table.insert(medias, v)
        vlc.msg.info("end update loop")
    end
end


function recursive_parse(folder_id, level)
    if not folder_id or level <= 0 then return nil end
    local page = query_folder(video_url, video_id, folder_id)
    local folders = parse_folders(page)
    local medias = parse_medias(page)
    vlc.msg.info("end medias")
    for k,v in pairs(folders) do
        vlc.msg.info("begin folders")
        vlc.msg.info(v.id)
        vlc.msg.info(v.name)
        local new_medias = recursive_parse(v.id, level - 1)
        update_medias(medias, new_medias, folder)
    end
    return medias
end

function print_medias(medias)
    for k,v in pairs(medias) do
        if v.url then vlc.msg.info("url: " .. v.url) end
        if v.filename then  vlc.msg.info("filename: " .. v.filename) end
        if v.video_quality then vlc.msg.info("quality: " .. v.video_quality) end
        if v.series then vlc.msg.info("series: " .. v.series) end
    end
end


-- Probe function.
function probe()
    -- fs.to support only http
    if vlc.access ~= "http" then
        return false
    end
    return ( string.match(vlc.path, "fs.to/video/" )
        or string.match(vlc.path, "fs.to/audio/" ))
end


-- parse function
function parse()
    video_url = get_canonical()
    video_id = get_id(video_url)
    local medias = recursive_parse("0", 10)
    vlc.msg.info("end")
    print_medias(medias)
    local playlist = {}
    for k,v in pairs(medias) do
        local item = {}
        item.path = v.url
        table.insert(playlist, item)
    end
    return playlist
end
