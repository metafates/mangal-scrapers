----------------------------------------
-- @name    Manganelo 
-- @url     https://m.manganelo.com/wwww
-- @author  metafates 
-- @license MIT
----------------------------------------




----- IMPORTS -----
Html = require("html")
Http = require("http")
--- END IMPORTS ---




----- VARIABLES -----
Client = Http.client()
Base = "https://ww5.manganelo.tv"
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
    local request = Http.request("GET", Base .. "/search/" .. query)
    local result = Client:do_request(request)

    local doc = Html.parse(result.body)
    local mangas = {}

    doc:find(".item-title"):each(function (i, s)
        local manga = { name = s:text(), url = Base .. s:attr("href") }
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

    doc:find(".chapter-name"):each(function (i, s)
        local chapter = { name = s:text(), url = Base .. s:attr("href") }
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

    doc:find(".container-chapter-reader img"):each(function (i, s)
        local page = { index = i, url = s:attr("data-src") }
        pages[i+1] = page
    end)

    return pages
end

--- END MAIN ---




----- HELPERS -----
function Reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i],t[n] = t[n],t[i]
        i = i + 1
        n = n - 1
    end
end
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
