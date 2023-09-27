--------------------------------------
-- @name    Mangatoto / Bato.to
-- @url     https://mangatoto.com/
-- @author  mpiva
-- @license MIT
--------------------------------------




----- IMPORTS -----
Html = require("html")
Time = require("time")
Http = require("http")
HttpUtil = require("http_util")
Headless = require("headless")


--- END IMPORTS ---




----- VARIABLES -----
Client = Http.client()
Browser = Headless.browser()
Base = "https://mangatoto.com"
Delay = 3 -- seconds
--- END VARIABLES ---


----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
	query = query:gsub("’","'")
	local url = Base .. "/search?word=" .. HttpUtil.query_escape(query)
	local request = Http.request("GET", url)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)
    local mangas = {}
	local doc2 = doc:find("#series-list"):first()
	local cnt = 0
    doc2:find(".no-flag"):each(function (i, r)
			local s = r:find(".item-title"):first()
			local manga = { name = trim(s:text():gsub("’","'"):gsub(" %[𝙾𝚏𝚏𝚒𝚌𝚒𝚊𝚕%]","")), url = Base .. s:attr("href") }
			mangas[cnt+1] = manga
			cnt = cnt + 1
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
	local doc2 = doc:find(".main"):first()
    doc2:find(".chapt"):each(function (i, s)
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
    local page = Browser:page()
	page:navigate(chapterURL)
	page:waitLoad()
	Time.sleep(Delay)
	local element = page:has("div[id='viewer'] > div > img")
	local doc = Html.parse(page:html())
	local pages = {}
	doc:find("#viewer > div"):each(function (i, s)
		local img = s:find("img"):first();
		local p = { index = i, url = trim(img:attr("src"):gsub("[\n\r\t]",""))  }
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
