-----------------------------------
-- @name    mangabat 
-- @url     https://h.mangabat.com/
-- @author  ahmadreza 
-- @license MIT
-----------------------------------


---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
Html = require("html")
Time = require("time")
Http = require("http")
HttpUtil = require("http_util")
--- END IMPORTS ---




----- VARIABLES -----
Client = Http.client()
Base = "https://www.mangakakalot.is"
Delay = 1 -- seconds
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	query = query:gsub("’","'")
	local url = Base .. "/search/manga/" .. HttpUtil.query_escape(query)
	local request = Http.request("GET", url)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)
    local mangas = {}
    doc:find(".list-story-item"):each(function (i, r)		
        local url = r:find("a.item-img"):attr("href")
        local s = r:find("a.item-title"):first()
        local chaps = basename(url)
        local manga = { name = trim(s:text():gsub("’","'")), url = chaps }
        mangas[i+1] = manga
    end)
    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
    local request = Http.request("GET", mangaURL)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)

    local chapters = {}
	local doc2 = doc:find(".row-content-chapter"):first()
    doc2:find(".a-h"):each(function (i, s)
        local data = r:find("a.chapter-name")
        local url = r:attr("href");
        local chapter = { name = trim(data:text()), url = url }
        chapters[i+1] = chapter
    end)

    Reverse(chapters)

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
    local request = Http.request("GET", chapterURL)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)

    local pages = {}

    doc:find(".container-chapter-reader img"):each(function (i, s)
        local page = { index = i, url = s:attr("src") }
        pages[i+1] = page
    end)

    return pages
end

--- END MAIN ---




----- HELPERS -----
function basename(path)
    return path:sub(path:find("-[^-]*$") + 1)
end

function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function Reverse(t)
    
	local n = #t
	local i = 1
	while i < n do
		t[i], t[n] = t[n], t[i]
		i = i + 1
		n = n - 1
	end
end
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
