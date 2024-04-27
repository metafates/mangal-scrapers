--------------------------------
-- @name    ManhwaUs
-- @url     https://manhwaus.net
-- @author  shurizzle
-- @license MIT
--------------------------------

---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }

----- IMPORTS -----
Http = require("http")
HttpUtil = require("http_util")
Json = require("json")
Html = require("html")
--- END IMPORTS ---

----- VARIABLES -----
Client = Http.client()
BASE = "https://manhwaus.net"
--- END VARIABLES ---

----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	local body = "search_query=" .. HttpUtil.query_escape(query)
	local request = Http.request("POST", BASE .. "/s/", body)
	request:header_set("Content-Type", "application/x-www-form-urlencoded")
	local result = Client:do_request(request)
	local result_body = Json.decode(result.body)
	local mangas = {}

	for _, item in pairs(result_body) do
		table.insert(mangas, { name = item.name, url = BASE .. "/webtoon/" .. item.slug })
	end

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

	doc:find(".panel-manga-chapter .row-content-chapter a.chapter-name"):each(function(_, s)
		table.insert(chapters, 1, { url = BASE .. s:attr("href"), name = s:text() })
	end)

	return chapters
end

--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
	local request = Http.request("GET", chapterURL)
	local result = Client:do_request(request)
	local doc = Html.parse(result.body)
	local i = 1
	local pages = {}

	doc:find(".read-content img"):each(function(_, s)
		table.insert(pages, { url = s:attr("src"), index = i })
		i = i + 1
	end)

	return pages
end

--- END MAIN ---

----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
