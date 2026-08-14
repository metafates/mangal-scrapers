----------------------------------------
-- @name    Sushiscan 
-- @url     https://sushiscan.fr
-- @author  https://github.com/0x697A756B69
-- @license MIT
-------------------------------------




----- IMPORTS -----
Http = require("http")
Html = require("html")
HttpUtil = require("http_util")
Time = require("time")
--- END IMPORTS ---




----- VARIABLES -----
Client = Http.client()
Base = "https://sushiscan.fr"
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
    local mangas = {}
    local search_url = Base .. "/?s=" .. HttpUtil.query_escape(query)

    for page = 1, 5 do
        local page_url = page == 1 and search_url or search_url .. "&paged=" .. page
        local result = Fetch(page_url, 3, 1)
        local doc = Html.parse(result.body)

        local before = #mangas
        doc:find(".bsx > a"):each(function(i, s)
            local name = s:attr("title")
            local url = s:attr("href")
            if name ~= nil and url ~= nil then
                mangas[#mangas + 1] = { name = name, url = url }
            end
        end)

        if #mangas == before then
            break
        end

        Time.sleep(1)
    end

    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL URL of the manga
-- @return Table of tables with the following fields: name, url
function MangaChapters(mangaURL)
    local result = Fetch(mangaURL, 3, 1)
    local doc = Html.parse(result.body)

    local chapters = {}

    doc:find(".eph-num"):each(function (i, s)
        local link = s:find("a"):first()
        if link ~= nil then
            local url = link:attr("href")
            local name = link:find(".chapternum")
            if url ~= nil and url ~= "" and name ~= nil and not url:match("^javascript:") then
                if url:match("^//") then
                    url = "https:" .. url
                elseif url:match("^/") then
                    url = Base .. url
                end
                local chapter = { name = name:text(), url = url }
                chapters[#chapters + 1] = chapter
            end
        end
    end)

    Reverse(chapters)

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL URL of the chapter
-- @return Table of tables with the following fields: url, index
function ChapterPages(chapterURL)
    local result = Fetch(chapterURL, 3, 1)
    local doc = Html.parse(result.body)

    local pages = {}

    doc:find("#readerarea img"):each(function(i, s)
        local src = s:attr("data-src")
        if src == nil or src == "" then
            src = s:attr("src")
        end
        if src ~= nil and src ~= "" then
            if src:match("^//") then
                src = "https:" .. src
            elseif src:match("^/") then
                src = Base .. src
            end
            local page = { index = #pages + 1, url = src }
            pages[#pages + 1] = page
        end
    end)

    return pages
end

--- END MAIN ---




----- HELPERS -----
--- Performs a request with transient retries.
-- Retries on transport errors, with backoff.
-- @param url string
-- @param attempts number
-- @param base_delay number
-- @return Table of tables with the following fields: code, body, headers
function Fetch(url, attempts, base_delay)
    local err
    for attempt = 1, attempts do
        local request = Http.request("GET", url)
        local result, e = Client:do_request(request)
        if result ~= nil then
            return result
        end
        err = e
        if attempt < attempts then
            Time.sleep(base_delay * 2^(attempt - 1))
        end
    end
    error("Sushiscan: " .. attempts .. " attempts failed: " .. tostring(err))
end

function Reverse(t)
    local n, i = #t, 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
end
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua