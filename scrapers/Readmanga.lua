--------------------------
-- @name    Readmanga 
-- @url     https://readmanga.live/
-- @author  https://github.com /ts-vadim
-- @license MIT
--------------------------


---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
html = require("html")
http = require("http")
HttpUtil = require("http_util")
inspect = require("inspect")
strings = require("strings")
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
	return {}
end

--- END MAIN ---


--- DEBUG ---
if DEBUG then

    -- query = "klinok__rassekaiuchii_demonov__A5327"
    query = "moia_liubov_999_urovnia_k_iamada_kunu__A5274/"

    -- print(inspect(MangaChapters(URL_BASE .. query)))
    print(inspect(SearchManga("one punch man")))

    -- local request = http.request("GET", URL_BASE .. query)
    -- local result = client:do_request(request)
    -- local doc = html.parse(result.body)

    -- name = doc:find(".name"):text()
    -- orig_name = doc:find(".original-name"):text()
    -- eng_name = doc:find(".eng-name"):text()
    -- summary = doc:find(".manga-description div span"):text()
    -- author = doc:find(".elem_author a"):text()
    -- genres = ""
    -- doc:find(".elem_genre a"):each(function(i,s)
    --     genres = genres .. s:text() .. ","
    -- end)
    -- chapters = {}
    -- doc:find(".chapters-link a.chapter-link"):each(function(i,s)
    --     chapter = strings.trim_space(s:text())
    --     href = s:attr("href")
    --     path = strings.split(strings.trim(href, "/"), "/")
    --     print("\"" .. chapter .. "\"")
    -- end)

    -- print("Name: " .. name)
    -- print("Original name: " .. orig_name)
    -- print("English name: " .. eng_name)
    -- print("Author: " .. author)
    -- print("Summary: " .. summary)
    -- print("Genres: " .. genres)

end
--- END DEBUG ---


-- ex: ts=4 sw=4 et filetype=lua
