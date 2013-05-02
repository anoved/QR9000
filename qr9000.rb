#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'
require 'rqrcode_png'
require 'yaml'

config = YAML.load_file('qr9000.yml')

twitter = Twitter::Client.new(config[:authentication])

begin
	# :include_entities => true (default)
	twitter.mentions(:since_id => config[:mostRecentMentionId], :include_entities => true).each do |mention|
	
		# This is now the most recent mention inspected - don't try to reply again
		if mention.id > config[:mostRecentMentionId] then config[:mostRecentMentionId] = mention.id end
		
		# Ignore mentions that don't match expected format…
		if !mention.text.match(/^(@QR9000\s+)(.+)$/i) then next end

		# …but extract the content of any matches ($~ is the last MatchData)
		offset = $~.captures[0].length
		content = $~.captures[1]
		
		# newtext is a copy of content, but with any t.co URLs expanded to original.
		laststart = 0
		newtext = ''
		mention.urls.each do |url|
			# if there is no text before the URL, this will fail with index - offset = 0 & 0 - 1 = -1,
			# inserting the whole content string ([0..-1]) instead of nothing.
			if url.indices[0]-1 > offset then newtext += content[laststart..(url.indices[0]-1-offset)] end
			newtext += url.expanded_url
			laststart = url.indices[1]-offset
		end
		newtext += content[laststart..-1]
		
		puts format("\"%s\"", mention.text)
		puts format("\"%s\"", content)
		puts format("\"%s\"", newtext)
		
		# (consider logging id/text/timestamp)
		
		# Need to specify :size explicity to ensure big enough QR version to fit data.
		# It's surprising rqrcode doesn't provide a method to select appropriate version automatically.
		qr = RQRCode::QRCode.new(content, :size => 5)
		
		# Generate a PNG image of the QR code
		png = qr.to_img.resize(480, 480)
		
		# Post the QR code image in reply; rgb format explicit (default grayscale PNG appears to confuse Twitter)
		#reply = twitter.update_with_media(format("@%s ", mention.user.screen_name), png.to_datastream(:fast_rgb), :in_reply_to_status_id => mention.id)
		# Also, validate reply response.
		
	end
rescue Twitter::Error => e
	puts STDERR, e
end

# Update config file with mostRecentMentionId
#File.open('qr9000.yml', 'w') {|file| YAML.dump(config, file)}
