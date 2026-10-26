# Checks the SEO basics on blog posts before they merge.
#
#   ruby .github/scripts/check_posts.rb [BASE_REF]
#
# Every published post needs a title and a description (the search snippet).
# With BASE_REF, a published post must also keep its URL, and an edited one
# must move last_modified_at forward so the sitemap tells search engines to
# recrawl it.

require "date"
require "open3"
require "yaml"

POSTS_DIR = "_posts"

def front_matter(text)
  match = text.match(/\A---\s*\n(.*?)\n---\s*(\n|\z)/m)
  return {} unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
end

def published?(data)
  data["published"] != false
end

# Jekyll's default permalink: /:categories/:year/:month/:day/:title.html
def post_url(path, data)
  return data["permalink"] if data["permalink"]

  slug = File.basename(path, File.extname(path)).sub(/\A\d{4}-\d{2}-\d{2}-/, "")
  date = data["date"] ? Date.parse(data["date"].to_s) : Date.parse(File.basename(path)[0, 10])
  categories = Array(data["categories"]).flat_map { |c| c.to_s.split }

  "/" + (categories + [date.strftime("%Y/%m/%d"), "#{slug}.html"]).join("/")
end

def base_file(base, path)
  out, status = Open3.capture2("git", "show", "#{base}:#{path}", err: File::NULL)
  status.success? ? out.force_encoding("UTF-8") : nil
end

def base_posts(base)
  out, status = Open3.capture2("git", "ls-tree", "--name-only", base, "#{POSTS_DIR}/")
  abort "Cannot read #{base}; fetch it first." unless status.success?
  out.split("\n")
end

def modified_on(data)
  value = data["last_modified_at"]
  value && Date.parse(value.to_s)
end

def check(base)
  errors = []
  current = Dir.glob("#{POSTS_DIR}/*.{md,markdown}")

  current.each do |path|
    data = front_matter(File.read(path, encoding: "UTF-8"))
    next unless published?(data)

    %w[title description].each do |key|
      errors << "#{path}: add `#{key}:` to the front matter" if data[key].to_s.strip.empty?
    end
  end

  return errors unless base

  base_posts(base).each do |path|
    text = base_file(base, path)
    data = front_matter(text)
    next unless published?(data)

    unless File.exist?(path)
      errors << "#{path}: a published post was renamed or deleted, which breaks its URL"
      next
    end

    now_text = File.read(path, encoding: "UTF-8")
    now_data = front_matter(now_text)
    next unless published?(now_data)

    if post_url(path, now_data) != post_url(path, data)
      errors << "#{path}: its URL changed from #{post_url(path, data)}; keep the date and categories"
    end

    next if now_text == text

    before = modified_on(data)
    after = modified_on(now_data)
    if after.nil? || (before && after <= before)
      errors << "#{path}: edited, so set `last_modified_at:` to today's date"
    end
  end

  errors
end

errors = check(ARGV[0])
if errors.empty?
  puts "Posts look good."
else
  puts errors
  exit 1
end
