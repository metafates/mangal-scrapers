-------------------------------------
-- @name    LuminousScans 
-- @url     https://luminousscans.com
-- @author  metafates 
-- @license MIT
-------------------------------------




----- IMPORTS -----
Http = require("http")
Headless = require("headless")
Html = require("html")
Time = require("time")
--- END IMPORTS ---




----- VARIABLES -----
Client = Http.client()
Browser = Headless.browser()
Page = Browser:page()
Base = "https://luminousscans.com"
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
    local request = Http.request("GET", Base .. "/?s=" .. query)
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)

    local mangas = {}

    doc:find(".bsx > a"):each(function(i, s)
        local manga = { url = s:attr("href"), name = s:attr("title") }
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

    doc:find("#chapterlist ul li"):each(function(_, s)
        local n, _ = s:attr("data-num")
        local index = tonumber(n)
        local url = s:find("a"):first():attr("href")
        local name = s:find("span"):first():text()

        local chapter = { url = url, name = name }
        if index == nil then
        return
        end

        chapters[index] = chapter
    end)

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL URL of the chapter
-- @return Table of tables with the following fields: url, index
function ChapterPages(chapterURL)
    Page:navigate(chapterURL)
    Time.sleep(1)

    local pages = {}

    for i, v in ipairs(Page:elements("#readerarea p > img")) do
        pages[i+1] = { index = i, url = v:attribute("src") }
    end

    return pages
end

--- END MAIN ---




----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
