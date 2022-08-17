-- Asura Scans
-- https://www.asurascans.com

local html = require("html")
local headless = require('headless')
local browser = headless.browser()
local page = browser:page()

local base = "https://www.asurascans.com"

local delay = 1 -- seconds

function SearchManga(query)
  local url = base .. "/?s=" .. query
  page:navigate(url)
  Sleep(delay)

  local mangas = {}

  for i, v in ipairs(page:elements(".bsx > a")) do
    local manga = { url = v:attribute('href'), name = v:attribute('title') }
    mangas[i + 1] = manga
  end

  return mangas
end

function MangaChapters(manga_url)
  page:navigate(manga_url)
  Sleep(delay)

  local chapters = {}

  for _, v in ipairs(page:elements("#chapterlist > ul li")) do
    local n = tonumber(v:attribute("data-num"))
    local elem = html.parse(v:html())
    local link = elem:find("a"):first()

    local chapter = { url = link:attr("href"), name = link:find("span"):first():text() }

    if n ~= nil then
      chapters[n] = chapter
    end
  end

  return chapters
end

function ChapterPages(chapter_url)
  page:navigate(chapter_url)
  Sleep(delay)

  local pages = {}
  for i, v in ipairs(page:elements("#readerarea p img")) do
    local p = { index = i, url = v:attribute("src") }
    pages[i + 1] = p
  end

  return pages
end

function Sleep(s)
    local sec = tonumber(os.clock() + s)
    while (os.clock() < sec) do
    end
end


