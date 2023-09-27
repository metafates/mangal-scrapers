--------------------------------------
-- @name    MangaKakalot
-- @url     https://www.mangakakalot.is/
-- @author  mpiva
-- @license MIT
--------------------------------------




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
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
	query = query:gsub("’","'")
	local url = Base .. "/ajax/manga/search-suggest?keyword=" .. HttpUtil.query_escape(query)
	local request = Http.request("GET", url)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)
    local mangas = {}
    doc:find(".ss-item"):each(function (i, r)		
        local url = r:attr("href")
        local s = r:find(".manga-name"):first()
        local chaps = Base .. "/ajax/manga/list-chapter-volume?id=" .. basename(url)
        local manga = { name = trim(s:text():gsub("’","'")), url = chaps }
        mangas[i+1] = manga
    end)
    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL URL of the manga
-- @return Table of tables with the following fields: name, url
function MangaChapters(mangaURL)
    local request = Http.request("GET", mangaURL)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)

    local chapters = {}
	local doc2 = doc:find("#list-chapter-en"):first()
    doc2:find("a"):each(function (i, s)
        local chapter = { name = trim(s:text()), url = Base .. s:attr("href") }
        chapters[i+1] = chapter
    end)

    Reverse(chapters)

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL URL of the chapter
-- @return Table of tables with the following fields: url, index
function ChapterPages(chapterURL)
    local request = Http.request("GET", chapterURL)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)
    local pages = {}
    local element = doc:find("#reading"):first()
    local id = element:attr("data-reading-id")
    local chap = element:attr("data-reading-type")

    request = Http.request("GET", Base .. "/ajax/manga/images?id=" .. id .. "&type=" .. chap)
    result = Client:do_request(request)
    doc = Html.parse(result.body)
	doc:find(".card-wrap"):each(function (i, s)
		local p = { index = i, url = trim(s:attr("data-url"):gsub("[\n\r\t]",""))  }
		pages[i + 1] = p
    end)

    return pages
end



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
