----------------------------------
-- @name    scansmanga.me 
-- @url     https://scansmangas.me
-- @author  liamlawless21 
-- @license MIT
----------------------------------




----- IMPORTS -----
Html = require("html")
Http = require("http")

Time = require("time")
--- END IMPORTS ---




----- VARIABLES -----
Client = Http.client()

Base = "https://scansmangas.me/"

--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
--[[
Manga fields:
	name - string, required
 	url - string, required
	author - string, optional
	genres - string (multiple genres are divided by comma ','), optional
	summary - string, optional
--]]
-- @param query Query to search for
-- @return Table of mangas
function SearchManga(query)
	local request = Http.request("GET", Base .. "/?s=" .. query)
	local result = Client:do_request(request)

	local doc = Html.parse(result.body)
	local mangas = {}

	doc:find(".bigor > a"):each(function (i, s)
        	local manga = { name = s:attr("title"), url = s:attr("href") }
        	mangas[i+1] = manga
	end)

	return mangas
end


--- Gets the list of all manga chapters.
--[[
Chapter fields:
	name - string, required
	url - string, required
	volume - string, optional
	manga_summary - string, optional (in case you can't get it from search page)
	manga_author - string, optional 
	manga_genres - string (multiple genres are divided by comma ','), optional
--]]
-- @param mangaURL URL of the manga
-- @return Table of chapters
function MangaChapters(mangaURL)
	local request = Http.request("GET", mangaURL)
	local result = Client:do_request(request)
	local doc = Html.parse(result.body)
	local chapters = {}

	doc:find(".lchx.desktop > a"):each(function (i, s)
		local chapter = { name = s:attr("title"), url = s:attr("href") }
		chapters[i+1] = chapter
    	end)

	return chapters
end


--- Gets the list of all pages of a chapter.
--[[
Page fields:
	url - string, required
	index - uint, required
--]]
-- @param chapterURL URL of the chapter
-- @return Table of pages
function ChapterPages(chapterURL)
	local request = Http.request("GET", chapterURL)
	local result = Client:do_request(request)
	local doc = Html.parse(result.body)

	local pages = {}
	local number_of_pages = 0

	doc:find("select#page-list > option"):each(function (i, s)
		number_of_pages = number_of_pages + 1
	end)

	local url = doc:find(".img-responsive"):first():attr("src")
	
	local transformed_url = url:gsub("/[^/]+$", "/")

	for i = 1, number_of_pages do
		local page = { index = i, url = (transformed_url .. tostring(i) .. ".jpg") }
		pages[i] = page
	end


	return pages
end

--- END MAIN ---






----- HELPERS -----

--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
