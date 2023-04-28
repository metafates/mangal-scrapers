--------------------------
-- @name    Readmanga 
-- @url     https://readmanga.live/
-- @author  ts-vadim (https://github.com/ts-vadim)
-- @license MIT
--------------------------


---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
html = require("html")
http = require("http")
time = require("time")
HttpUtil = require("http_util")
inspect = require("inspect")
strings = require("strings")
json = require("json")
--- END IMPORTS ---


----- VARIABLES -----
DEBUG = true
URL_BASE = "https://readmanga.live/"
client = http.client()
--- END VARIABLES ---


----- HELPERS -----
function reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
end
--- END HELPERS ---


----- MAIN -----
--- Searches for manga with given query. 
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
    function parse_page_n(page_offset, mangas)
        local request = http.request("POST", URL_BASE .. "search/?q=" .. HttpUtil.query_escape(query))
        local result = client:do_request(request)
        local doc = html.parse(result.body)

        start = #mangas

        doc:find(".leftContent .tiles .tile .desc"):each(function(i,s)
            title = strings.trim_space(s:find("h3"):text())
            url = s:find("h3 a"):attr("href")
            
            -- 1. There will be mangas from unrelated sources like mintmanga.live
            -- 2. Sometimes it will recieve broken entries with a link to an author (cause idk what im doing)
            if strings.contains(url, "https://") or strings.contains(url, "/list/person") then
                return
            end

            mangas[start+i+1] = {
                name = title,
                url = URL_BASE .. strings.trim(url, "/"),
            }
        end)
    end
    
    mangas = {}
    -- Seems like the step is always 50
    parse_page_n(50, mangas)
    -- parse_page_n(100, mangas)

    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
	local request = http.request("GET", mangaURL)
    local result = client:do_request(request)
    local doc = html.parse(result.body)

    chapters = {}
    doc:find(".chapters-link a.chapter-link"):each(function(i,s)
        chapters[i+1] = {
            name = strings.trim_space(s:text()),
            url = URL_BASE .. strings.trim(s:attr("href"), "/"),
        }
    end)

    reverse(chapters)

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
    local request = http.request("GET", chapterURL)
    local result = client:do_request(request)
    h = result.body

    -- For some reason image URLs are passed to readerInit() function in bare HTML
    -- with some other arguments. So I'm trying to get just the urls here.
    json_start = h:find("rm_h.readerInit%(")
    json_start = h:find("%[", json_start)
    s = h:sub(json_start)
    s = s:sub(1, s:find("%)"))
    s = s:sub(1, #s - s:reverse():find("%]") + 1)
    s = "[" .. s:gsub("'", "\"") .. "]"
    j, e = json.decode(s)
    if e then
        error(e)
    end

    pages = {}
    for i,v in ipairs(j[1]) do
        url = v[1] .. v[3]
        url = url:sub(1, url:find("?") - 1)
        pages[i] = {
            url = url,
            index = i,
        }
    end

    return pages
end
--- END MAIN ---


-- ex: ts=4 sw=4 et filetype=lua
