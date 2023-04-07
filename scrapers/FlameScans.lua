--------------------------------------
-- @name    FlameScans
-- @url     https://www.flamescans.com
-- @author  metafates & belphemur
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
Base = "https://flamescans.org"
Delay = 1 -- seconds
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
    query = string.gsub(query, "’s", "")
    query = string.gsub(query, "'s", "")
    local url = Base .. "/?s=" .. query
    Page:navigate(url)
    Time.sleep(Delay)

    local mangas = {}

    for _, v in ipairs(Page:elements(".bsx > a")) do
        local manga = { url = v:attribute('href'), name = v:attribute('title') }
        table.insert(mangas, manga)
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

    for _, v in ipairs(Page:elements("#chapterlist > ul li")) do
        local n = tonumber(v:attribute("data-num"))
        local elem = Html.parse(v:html())
        local link = elem:find("a"):first()

        local chapter = { url = link:attr("href"), name = string.gsub(link:find("span"):first():text():sub(2),"\n"," ") }

        if n == nil then
            goto continue
        end

        if string.find(tostring(n), '%.') then
            goto continue
        end

        if n == 0 then
            goto continue
        end

        chapters[n] = chapter

        ::continue::
    end

    return chapters
end



--- Gets the list of all pages of a chapter.
-- @param chapterURL URL of the chapter
-- @return Table of tables with the following fields: url, index
function ChapterPages(chapterURL)
    Page:navigate(chapterURL)
    Time.sleep(Delay)

    local pages = {}
    for i, v in ipairs(Page:elements("#readerarea p img")) do
        local p = { index = i, url = v:attribute("src") }
        pages[i + 1] = p
    end

    return pages
end

--- END MAIN ---




----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
