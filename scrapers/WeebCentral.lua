------------------------------------
-- @name    WeebCentral
-- @url     https://weebcentral.com/
-- @author  stavguo
-- @license MIT
------------------------------------


---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
Html = require("html")
Http = require("http")
HttpUtil = require("http_util")
Headless = require("headless")
Strings = require("strings")
Time = require("time")
--- END IMPORTS ---




----- VARIABLES -----
Client = Http.client()
Browser = Headless.browser()
Base = "https://weebcentral.com"
Delay = 0.5
Timeout = 10
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
    local page = Browser:page()
    page:navigate(Base .. "/search?text=" .. HttpUtil.query_escape(query))
    page:waitLoad()

    local startTime = Time.unix()

    while Time.unix() - startTime < Timeout do
        if page:has("div.alert > span") then
            local alertText = page:element("div.alert > span"):text()
            if alertText == "No results found" then
                return {}
            end
        end

        if page:has("article") then
            local doc = Html.parse(page:html())
            local mangas = {}

            doc:find("article.flex"):each(function(i, s)
                local manga = {
                    name = s:find("abbr.no-underline"):first():attr("title"),
                    url = s:find("abbr.no-underline > a"):first():attr("href")
                }
                mangas[i + 1] = manga
            end)

            return mangas
        end

        Time.sleep(Delay)
    end

    return {}
end

--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
    local page = Browser:page()
    page:navigate(mangaURL)
    page:waitElementsMoreThan("#chapter-list > div", 0)
    if page:has("#chapter-list > button") == true then
        page:element("#chapter-list > button"):click()
        page:waitElementsMoreThan("#chapter-list > div", 9)
    end

    local doc = Html.parse(page:html())

    local chapters = {}

    doc:find("#chapter-list > div"):each(function(i, s)
        local name = s:find('span[class=""]'):first():text()
        name = Strings.trim(name:gsub("[\r\t\n]+", " "), " ")
        local url = s:find("a"):first():attr("href")
        local chapter = { name = name, url = url }
        chapters[i + 1] = chapter
    end)

    Reverse(chapters)

    return chapters
end

--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
    local page = Browser:page()
    page:navigate(chapterURL)
    page:waitElementsMoreThan("img.mx-auto", 0)
    local doc = Html.parse(page:html())

    local pages = {}

    doc:find("img.mx-auto"):each(function(i, s)
        local pageNumber = i + 1
        local chapterPage = { index = pageNumber, url = s:attr("src") }
        pages[pageNumber] = chapterPage
    end)

    return pages
end

--- END MAIN ---




----- HELPERS -----
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
