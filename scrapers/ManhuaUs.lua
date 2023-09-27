--------------------------------------
-- @name    ManhuaUs
-- @url     https://manhuaus.com/
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
Base = "https://manhuaus.com/"
Delay = 1 -- seconds
--- END VARIABLES ---


----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
	query = query:gsub("’","'")
	local url = Base .. "?s=" .. HttpUtil.query_escape(query) .. "&post_type=wp-manga&op=&author=&artist=&release=&adult=";
	local request = Http.request("GET", url)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)
    local mangas = {}
	local doc2 = doc:find(".c-tabs-item"):first()
    doc2:find(".row"):each(function (i, r)
		local s = r:find(".post-title"):first()
		s = s:find("a"):first()
        local manga = { name = trim(s:text():gsub("’","'")), url = s:attr("href") }
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
	local doc2 = doc:find(".listing-chapters_wrap"):first()
    doc2:find("a"):each(function (i, s)
        local chapter = { name = trim(s:text()), url = s:attr("href") }
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
	doc:find(".reading-content > div"):each(function (i, s)
		local img = s:find("img"):first();
		local p = { index = i, url = trim(img:attr("data-src"):gsub("[\n\r\t]",""))  }
		pages[i + 1] = p
    end)

    return pages
end



----- HELPERS -----

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
