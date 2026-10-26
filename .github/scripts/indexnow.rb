# Tells IndexNow (Bing, Yandex, and the AI search built on them) which pages
# changed, so they recrawl within minutes. Google ignores IndexNow; it reads
# the sitemap instead.
#
#   ruby .github/scripts/indexnow.rb docs/sitemap.xml KEY [CHANGED_FILE...]
#
# CHANGED_FILE is a built file under docs/. Only sitemap pages among them are
# sent; with none given, every sitemap page is. A failed ping never fails
# the deploy.

require "json"
require "net/http"
require "uri"

def page_urls(sitemap)
  File.read(sitemap, encoding: "UTF-8").scan(%r{<loc>\s*(.*?)\s*</loc>}).flatten
end

# docs/a/b.html -> /a/b.html, docs/about/index.html -> /about/
def path_for(file)
  "/" + file.sub(%r{\Adocs/}, "").sub(%r{(\A|/)index\.html\z}, '\1')
end

def changed_urls(urls, files)
  return urls if files.empty?

  paths = files.map { |f| path_for(f) }
  urls.select { |url| paths.include?(URI(url).path) }
end

sitemap, key, *files = ARGV
abort "usage: indexnow.rb SITEMAP KEY [CHANGED_FILE...]" unless sitemap && key

urls = changed_urls(page_urls(sitemap), files)
if urls.empty?
  puts "IndexNow: no changed pages to send."
  exit
end

host = URI(urls.first).host
body = { host: host, key: key, keyLocation: "https://#{host}/#{key}.txt", urlList: urls }

puts "IndexNow: sending #{urls.size} page(s)"
puts urls

begin
  response = Net::HTTP.post(
    URI("https://api.indexnow.org/indexnow"),
    body.to_json,
    "Content-Type" => "application/json; charset=utf-8",
  )
  puts "IndexNow: #{response.code}"
  puts "::warning::IndexNow returned #{response.code}" unless response.code.start_with?("2")
rescue StandardError => e
  puts "::warning::IndexNow ping failed: #{e.class}"
end
