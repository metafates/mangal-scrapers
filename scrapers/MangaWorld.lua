--------------------------------------
-- @name    MangaWorld (IT) 
-- @url     https://www.mangaworld.ac
-- @author  bonny1992 
-- @license MIT
--------------------------------------




----- IMPORTS -----
Html = require("html")
Headless = require('headless')
Time = require("time")
--- END IMPORTS ---




----- VARIABLES -----
Browser = Headless.browser()
Page = Browser:page()
Base = "https://www.mangaworld.ac"
Delay = 1 -- seconds
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
    local url = Base .. "/archive?keyword=" .. query
    Page:navigate(url)
    Time.sleep(Delay)

    local mangas = {}

    for i, v in ipairs(Page:elements(".comics-grid > .entry > a")) do
        local manga = { url = v:attribute('href'), name = v:attribute('title') }
        mangas[i + 1] = manga
    end
    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL URL of the manga
-- @return Table of tables with the following fields: name, url
function MangaChapters(mangaURL)
    Page:navigate(mangaURL)
    Time.sleep(Delay)

    local chapters = {}

    for _, v in ipairs(Page:elements(".chapter > .chap")) do
        local numStr = v:attribute('title')
        local n = tonumber(numStr:match("%d+%.?%d*"))
        local elem = Html.parse(v:html())
        local link = elem:find("a"):first()

        local chapter = { url = link:attr("href"), name = link:find("span"):first():text() }

        if n ~= nil and math.floor(n) == n and n ~= 0 then
            chapters[n] = chapter
        end
    end
    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL URL of the chapter
-- @return Table of tables with the following fields: url, index
function ChapterPages(chapterURL)
    Page:navigate(chapterURL .. "/1?style=list")
    Time.sleep(Delay)

    local pages = {}
    for i, v in ipairs(Page:elements("div#page img")) do
        local p = { index = i, url = v:attribute("src") }
        pages[i + 1] = p
    end

    return pages
end

--- END MAIN ---




----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
