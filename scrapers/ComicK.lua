-- ComicK
-- https://comick.fun/
-- API Reference: https://api.comick.fun/docs/static/index.html

local http = require('http')
local json = require('json')
local client = http.client()

local api_base = 'https://api.comick.fun'
local image_base = 'https://meo3.comick.pictures'
local limit = 50  -- Limit on Number of Chapters per Page of Results
                  -- `MangaChapters()` will display all results regardless
                  -- of the value of this variable by iterating through
                  -- all the pages
local lang = 'en' -- Language: en = english, fr = french, etc.
local order = 1   -- Chapter Order: 0 = descending, 1 = ascending

function SearchManga(query)
  local request_url = api_base .. '/search?&q=' .. query
  local request = http.request('GET', request_url)
  local result = client:do_request(request)
  local result_body = json.decode(result['body'])

  local mangas = {}
  local i = 1

  for key, val in pairs(result_body) do
     local title = val['title']
     local id = val['id']
     local link = api_base .. '/comic/' .. tostring(id) .. '/chapter'
     local manga = { url = link, name = title }

     mangas[i] = manga
     i = i + 1
  end

  return mangas
end

function MangaChapters(manga_url)
  local request_url = manga_url .. '?lang=' .. lang .. '&limit=' .. limit .. '&chap-order=' .. order
  local chapters = {}
  local i = 1

  local request = http.request('GET', request_url)
  local result = client:do_request(request)
  local result_body = json.decode(result['body'])
  local num_chapters = result_body['total']
  local num_pages = math.ceil(num_chapters / limit)

  for j = 1, num_pages do
    request = http.request('GET', request_url .. '&page=' .. j)
    result = client:do_request(request)
    result_body = json.decode(result['body'])

    for key, val in pairs(result_body['chapters']) do
        local hid = val['hid']
        local num = val['chap']
        local title = val['title']
        local chap = 'Chapter ' .. tostring(num)
        local group_name = val['group_name']

        if title then
            chap = chap .. ': ' .. tostring(title)
        end

        chap = chap .. ' ['
        for key, val in pairs(group_name) do
            if key ~= 1 then
            chap = chap .. ', '
            end

            chap = chap .. tostring(val)
        end
        chap = chap .. ']'

        local link = api_base .. '/chapter/' .. tostring(hid)
        local chapter = { url = link, name = chap }

        chapters[i] = chapter
        i = i + 1
    end
  end

  return chapters
end

function ChapterPages(chapter_url)
  local request = http.request('GET', chapter_url)
  local result = client:do_request(request)
  local result_body = json.decode(result['body'])
  local chapter_table = result_body['chapter']

  local pages = {}
  local i = 1

  for key, val in pairs(chapter_table['md_images']) do
     local ind = key
     local link = image_base .. '/' .. val['b2key']
     local page = { url = link, index = ind }

     pages[i] = page
     i = i + 1
  end

  return pages
end
