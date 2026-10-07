#!/usr/bin/env ruby
# frozen_string_literal: true
# Dump every hidden check in an ai-evals-style corpus with assertion-style tags.
# usage: ruby checks.rb <tasks_dir> [prefix-filter]
# Prints: task | n_checks | per-check: name [tags]
require "pathname"
tasks = Pathname(ARGV[0]).children.select(&:directory?).sort
filter = ARGV[1]
TAGS = {
  http:       /\b(get|post|patch|put|delete|head)\s+[\w\/\(\"':]/,
  response:   /assert_response|assert_redirected_to|response\.(body|status|headers|parsed_body)|assert_select|assert_dom/,
  model:      /\.(reload|create!?|update!?|save!?|destroy!?|find_by|where|count|exists\?|pluck|first|last)\b/,
  job:        /perform_enqueued_jobs|assert_enqueued|assert_performed|assert_no_enqueued|ActiveJob/,
  storage:    /ActiveStorage|\.blob\b|\.attached\?|variant|purge|service\.exist/,
  broadcast:  /assert_broadcast|assert_turbo_stream_broadcast|ActionCable|Turbo::StreamsChannel|broadcast/,
  cache:      /Rails\.cache|cache_key|fragment|\bcache\b/,
  mail:       /ActionMailer|assert_emails|deliveries/,
  time:       /travel_to|travel\b|freeze_time|sleep\b|Timeout/,
  logs:       /Rails\.logger|assert_logged|capture_io|\$stdout|StringIO|log\b/,
  fs_shell:   /`[^`]+`|system\(|Open3|File\.(read|exist|write)|Dir\.glob|IO\.popen/,
  db_schema:  /ActiveRecord::Base\.connection|columns_hash|schema|migration|index_exists/,
  source_grep:/File\.read\(.*(app|config|lib)|Rails\.root\.join\(.*\.(rb|erb|yml)/,
  system:     /\bvisit\b|Capybara|ApplicationSystemTestCase|click_on|assert_selector|fill_in|drag_to/,
  concurrency:/Thread\.new|Concurrent|Mutex|fork\b/,
}.freeze
tasks.each do |t|
  next if filter && !t.basename.to_s.start_with?(filter)
  src = t.join("verification_test.rb").read
  # split into test methods: from "def test_" to next "def test_" or end
  chunks = src.split(/(?=^\s*(?:def test_\w+|test\s+["']))/).select { it =~ /^\s*(?:def test_|test\s+["'])/ }
  puts "## #{t.basename}  (#{chunks.size} checks)"
  chunks.each do |c|
    name = c[/def (test_\w+)/, 1] || c[/\A\s*test\s+["'](.*?)["']\s+do/m, 1]
    tags = TAGS.select { |_, re| c.match?(re) }.keys
    puts "  - #{name} [#{tags.join(',')}]"
  end
end
