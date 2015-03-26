
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

function strip_tags(text)
    return string.gsub(text, "<[^>]+/?>", "")
end

function trim(s)
    return s:match "^%s*(.-)%s*$"
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

function quality_sort(medias)
    local res = {}
    local temp = {}

    for _,media in ipairs(medias) do
        local quality_key
        if not media.video_quality then        
            quality_key = "nil"
        else
            quality_key = media.video_quality
        end 
        
        if not temp[quality_key] then
            temp[quality_key] = {}
        end

        table.insert(temp[quality_key], media)
    end

    for _,quality in pairs(temp) do
        for _,media in ipairs(quality) do
            table.insert(res, media)
        end
    end
    
   return res 
end

function parse_folders(result)
    local res_obj = {}
    if not result then return nil end
    local folder_blocks = find_many(result, "<li class=\"folder[^<]->(.-)</li>")
    for _,v in ipairs(folder_blocks) do
        folder_obj = {}
        folder_id, folder_name = string.match(v, "<a href=\"#\".-rel=\"{parent_id: '?([0-9]*)'?.-}\">(.-)</a>")
        if folder_id and folder_name then
            folder_name = trim(strip_tags(folder_name))
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
    for _,v in ipairs(media_blocks) do
        vlc.msg.info("begin media")
        local media = {}
        _,_,video_quality = string.find(v, "<span class=\"video--qulaity.-\">([^<]+)</span>")
        _,_,filename = string.find(v, "<span[^>]*class=\".-filename--text\"[^>]*>([^<]+)</span>")
         _,_,series = string.find(v, "<span[^>]*class=\".-filename--series--num\"[^>]*>([^<]+)</span>")
        _,_,file_url = string.find(v, "<a.-href=\"(/get/.-)\"")
        media.video_quality = video_quality
        media.filename = filename
        media.series = series
        if file_url then
            media.url = "http://fs.to" .. vlc.strings.resolve_xml_special_chars(file_url)
        end
        table.insert(res_obj, media)
        vlc.msg.info("end media")
    end
    return res_obj
end


function update_medias(medias, new_medias, folder)
    vlc.msg.info("function update_medias")
    for _,v in ipairs(new_medias) do
        vlc.msg.info("begin update loop")
        if not v.folders then
            v.folders = {}
        end
        vlc.msg.info("Add folder " .. folder.name)
        table.insert(v.folders, folder)
        table.insert(medias, v)
        vlc.msg.info("end update loop")
    end
end


function recursive_parse(folder_id, level)
    if not folder_id or level <= 0 then return nil end
    local page = query_folder(video_url, video_id, folder_id)
    local folders = parse_folders(page)
    local medias = quality_sort(parse_medias(page))
    vlc.msg.info("end medias")
    for _,folder in ipairs(folders) do
        vlc.msg.info("begin folders")
        vlc.msg.info(folder.id)
        vlc.msg.info(folder.name)
        local new_medias = recursive_parse(folder.id, level - 1)
        update_medias(medias, new_medias, folder)
    end
    return medias
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
    local playlist = {}
    for _,v in ipairs(medias) do
        local item = {}
        local title;
        title = v.filename
        item.path = v.url
        item.name = v.filename
        if v.video_quality and v.series and v.filename then
            title = string.format("(%s) [%s] %s", v.series, v.video_quality, v.filename)
        elseif v.video_quality and v.filename then
            title = string.format("[%s] %s", v.video_quality, v.filename)
        elseif v.series and v.filename then
            title = string.format("(%s) %s", v.series, v.filename)
        end
        if v.folders then
            for _,folder in ipairs(v.folders) do
                title = folder.name.."/"..title
            end
        end
        item.title = title
        table.insert(playlist, item)
    end
    return playlist
end
