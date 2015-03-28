
function string_ends(text, ends)
    return ends == "" or string.sub(text, -string.len(ends)) == ends
end

function vlc_format(filename)
    -- https://wiki.videolan.org/VLC_Features_Formats#Format.2FContainer.2FMuxers
    local formats = {
        "3gp", "asf", "wmv", "au", "avi", "mka", "mkv", "flv", "mov", "mp4", 
        "ogg", "ogm", "ts", "mpg", "mp3", "mp2", "msc", "msv", "nut", "ra",
        "ram", "rm", "rv", "rmbv", "a52", "dts", "aac", "flac", "dv", "vid",
        "tta", "tac", "ty", "wav", "xa"}

    local lname = string.lower(filename)

    for _,v in ipairs(formats) do
        if string_ends(lname, "." .. v) then return true end
    end
    return false
end


function get_files()
    local res = {}
    while true do
        local line = vlc.readline()
        if not line then break end
        local download_url, filename = string.match(
            line, "<a[^>]+href='(/get/%d+)'[^>]+title[^>]+>(.-)</a>")

        if download_url and filename then
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
        vlc.msg.info(file.filename)
        if vlc_format(file.filename) then
            table.insert(playlist, {path=file.url, name=file.filename})
        end
    end
    return playlist
end
