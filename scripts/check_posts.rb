#!/usr/bin/env ruby
# frozen_string_literal: true

# SEO rules for posts in _posts/, run before every deploy and on pull requests.
#
#   ruby scripts/check_posts.rb [BASE_REF]
#
# Without BASE_REF only the front matter of each published post is checked.
# With BASE_REF (the commit being compared against) it also blocks changes that
# break a live URL, and edits that don't bump `last_modified_at`.

require "date"
require "open3"
require "yaml"

POSTS_DIR = "_posts"
DESCRIPTION_RANGE = 50..160
# Front matter that feeds the post's URL (permalink: /:categories/:year/:month/:day/:title.html).
URL_KEYS = %w[date categories permalink slug].freeze
DATE_KEYS = %w[last_modified_at modified_date].freeze

def front_matter(text)
  return [{}, text] unless text.start_with?("---")

  _, yaml, body = text.split(/^---\s*$/, 3)
  data = YAML.safe_load(yaml.to_s, permitted_classes: [Date, Time], aliases: true) || {}
  [data, body.to_s]
end

def published?(data)
  data.fetch("published", true) != false
end

def git(*args)
  out, _err, status = Open3.capture3("git", *args)
  status.success? ? out.force_encoding(Encoding::UTF_8) : nil
end

def base_version(base, path)
  text = git("show", "#{base}:#{path}")
  text && front_matter(text)
end

errors = []
warnings = []

Dir.glob("#{POSTS_DIR}/*.{md,markdown}").sort.each do |path|
  data, = front_matter(File.read(path, encoding: "UTF-8"))
  next unless published?(data)

  description = data["description"].to_s.strip
  if description.empty?
    errors << "#{path}: missing `description:` (it becomes the Google snippet)"
  elsif !DESCRIPTION_RANGE.cover?(description.length)
    warnings << "#{path}: description is #{description.length} characters; " \
                "#{DESCRIPTION_RANGE.min}-#{DESCRIPTION_RANGE.max} shows best in search results"
  end

  errors << "#{path}: missing `title:`" if data["title"].to_s.strip.empty?

  if (image = data["image"])
    errors << "#{path}: `image: #{image}` does not exist" unless File.exist?(image.to_s.sub(%r{\A/}, ""))
  else
    warnings << "#{path}: no `image:`, link previews use the default share image"
  end
end

base = ARGV[0]
if base && !base.empty? && base !~ /\A0+\z/ && git("cat-file", "-e", "#{base}^{commit}")
  changes = git("diff", "--name-status", "-M", base, "HEAD", "--", POSTS_DIR).to_s.lines
  changes.each do |line|
    status, old_path, new_path = line.chomp.split("\t")
    old_data, old_body = base_version(base, old_path)
    next unless old_data && published?(old_data)

    case status[0]
    when "D"
      errors << "#{old_path}: a published post was deleted, which breaks its live URL"
    when "R"
      errors << "#{old_path} -> #{new_path}: renaming a published post changes its URL"
    when "M"
      new_data, new_body = front_matter(File.read(old_path, encoding: "UTF-8"))
      next unless published?(new_data)

      URL_KEYS.each do |key|
        next if old_data[key] == new_data[key]

        errors << "#{old_path}: changing `#{key}:` changes the post's live URL"
      end

      edited = old_body != new_body ||
               old_data.reject { |k, _| DATE_KEYS.include?(k) } != new_data.reject { |k, _| DATE_KEYS.include?(k) }
      if edited && old_data["last_modified_at"] == new_data["last_modified_at"]
        errors << "#{old_path}: edited without bumping `last_modified_at:` " \
                  "(set it to today, e.g. last_modified_at: #{Date.today}) so Google recrawls it"
      end
    end
  end
end

warnings.each { |w| puts "warning: #{w}" }
errors.each { |e| puts "error: #{e}" }
if errors.empty?
  puts "Post checks passed."
else
  puts "\n#{errors.size} post check(s) failed."
  exit 1
end
