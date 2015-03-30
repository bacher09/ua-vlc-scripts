
function descriptor()
    return {title="movietrailers.com.ua", capabilities={"search"}}
end


function trim(s)
    return s:match "^%s*(.-)%s*$"
end


function parse_page(page_url)
    local sd = vlc.stream(page_url)
    if not sd then return nil end
    local page = sd:read(1024 * 1024)
    local res = {}
    local pattern = "<a%s+href=\"(/item/[^\"]+)\"%s+class=\"b%-search%-result[^\"]*\"%s*>(.-)</a>"

    for url, content in string.gmatch(page, pattern) do
        local _,_,title = string.find(content,
            "<span%s+class=\"[^\"]-%-title\">(.-)</span>")

        local _,_,art = string.find(content,
            "<span%s+class=\"[^\"]-%-poster\".-url%((http://.-)%)\">")

        local _,_,desc = string.find(content,
            "<span%s+class=\"[^\"]-%-description\">(.-)</span>")

        local _,_,ctype = string.find(content,
            "<span%s+class=\"[^\"]-subsection%-inner\">(.-)</span>")

        if url then
            url = "http://movietrailer.com.ua"..
                vlc.strings.resolve_xml_special_chars(url)

            table.insert(res, {url=url,
                               arturl=art,
                               title=title,
                               description=desc,
                               category=trim(ctype)})
        end
    end
    return res
end


function add_nodes(results)
    local node_cache = {}
    for _,item in ipairs(results) do
        if item.category then
            local key
            if item.category then
                key = item.category
            else
                key = "Other"
            end

            if not node_cache[key] then
                node_cache[key] = vlc.sd.add_node({title=key})
            end

            node_cache[key]:add_subitem({path=item.url,
                                         arturl=item.arturl,
                                         title=item.title,
                                         genre=item.category,
                                         description=item.description})
        end
    end
end

function search_url(query)
    return "http://movietrailer.com.ua/search/?q="..query
end

function search(query)
    vlc.sd.remove_all_items_nodes()
    local res = parse_page(search_url(query))
    add_nodes(res)
end


function main()
    vlc.msg.info("Main")
    --local res = parse_page(search_url("Breaking"))
    --add_nodes(res)
end
