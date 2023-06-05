--------------------------------------
-- @name    FlameScans
-- @url     https://www.flamescans.org
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
        local manga = { url = v:attribute('href'), name = v:attribute('title'), translator = "FlameScans" }
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
    local date_pattern = "(%w+)%s+(%d+),%s+(%d+)"
    local month_names = {
	January = "01", February = "02", March = "03", April = "04",
	May = "05", June = "06", July = "07", August = "08",
	September = "09", October = "10", November = "11", December = "12",
    }

    for _, v in ipairs(Page:elements("#chapterlist > ul li")) do
        local n = tonumber(v:attribute("data-num"))
        local elem = Html.parse(v:html())
        local link = elem:find("a"):first()
	local chapter_date = link:find(".chapterdate"):first():text()
	local iso_date = ""

	if chapter_date ~= nil then 
	    local month_name, day, year = chapter_date:match(date_pattern)
	    local month = month_names[month_name]

	    local timestamp = os.time({year=year, month=month, day=day})
	    iso_date = os.date("%Y-%m-%d", timestamp)
	end	

        local chapter = { url = link:attr("href"), name = string.gsub(link:find("span"):first():text():sub(2),"\n"," "), chapter_date=iso_date }

        repeat
            -- Skip this chapter if the number is nil
            if n == nil then
                break
            end

            -- Skip this chapter if the number is a floating-point number
            if math.floor(n) ~= n then
                break
            end

            -- Skip this chapter if the number is negative
            if n < 1 then
                break
            end

            -- Add this chapter to the list of chapters
            chapters[n] = chapter
        until true
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
