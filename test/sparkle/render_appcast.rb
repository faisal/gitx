#!/usr/bin/env ruby
# Renders docs/appcast.xml the way Jekyll would, against a fixture list of
# releases, so the Sparkle specs can inspect the feed without a Jekyll build.
#
# Usage: render_appcast.rb <template> <releases.json>

require "rubygems"
require "json"
require "liquid"
require "time"

module JekyllFilters
  def date_to_rfc822(value)
    Time.parse(value.to_s).rfc2822
  end

  def markdownify(value)
    value.to_s
  end
end
Liquid::Template.register_filter(JekyllFilters)

template_path, releases_path = ARGV
source = File.read(template_path)
body = source.sub(/\A---\n.*?\n---\n/m, "")

site = { "github" => { "project_title" => "GitX", "releases" => JSON.parse(File.read(releases_path)) } }
page = {}

puts Liquid::Template.parse(body).render("site" => site, "page" => page)
