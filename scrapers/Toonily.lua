--------------------------------------
-- @name    Toonily
-- @url     https://toonily.com/
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
Base = "https://toonily.com"
Delay = 1 -- seconds
--- END VARIABLES ---


----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
	query = query:gsub("’","'")
    local forms = "action=ajaxsearchpro_search&aspp=" .. HttpUtil.query_escape(query) .. "&asid=1&asp_inst_id=1_1&options=" .. HttpUtil.query_escape("filters_initials=0&filters_changed=0&qtranslate_lang=0&current_page_id=12")
    local request = Http.request("POST", Base .. "/wp-admin/admin-ajax.php", forms)
    request:header_set("Content-Type", "application/x-www-form-urlencoded")
    local result = Client:do_request(request)
    local doc = Html.parse(result.body)
    local mangas = {}

    doc:find(".asp_res_url"):each(function (i, s)
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
    doc:find(".wp-manga-chapter > a"):each(function (i, s)
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
