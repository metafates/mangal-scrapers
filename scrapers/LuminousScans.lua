-- Luminous Scans
-- https://luminousscans.com

local http = require('http')
local headless = require('headless')
local html = require('html')
local client = http.client()

local browser = headless.browser()
local page = browser:page()

local base = 'https://luminousscans.com'

function SearchManga(query)
  local request = http.request('GET', base .. '/?s=' .. query)
  local result = client:do_request(request)
  local doc = html.parse(result.body)

  local mangas = {}

  doc:find(".bsx > a"):each(function(i, s)
    local manga = { url = s:attr('href'), name = s:attr('title') }
    mangas[i+1] = manga
  end)

  return mangas
end

function MangaChapters(manga_url)
  local request = http.request('GET', manga_url)
  local result = client:do_request(request)
  local doc = html.parse(result.body)

  local chapters = {}

  doc:find("#chapterlist ul li"):each(function(_, s)
    local n, _ = s:attr('data-num')
    local index = tonumber(n)
    local url = s:find('a'):first():attr('href')
    local name = s:find('span'):first():text()

    local chapter = { url = url, name = name }
    if index == nil then
      return
    end

    chapters[index] = chapter
  end)

  return chapters
end

function ChapterPages(chapter_url)
  page:navigate(chapter_url)

  -- Wait until loaded. For some reason page:waitLoad() loads forever...
  Sleep(3)

  local pages = {}

  for i, v in ipairs(page:elements("#readerarea p > img")) do
    pages[i+1] = { index = i, url = v:attribute('src') }
  end

  return pages
end

function Sleep(s)
    local sec = tonumber(os.clock() + s)
    while (os.clock() < sec) do
    end
end
