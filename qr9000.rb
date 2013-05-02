#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'
require 'rqrcode_png'
require 'yaml'

config = YAML.load_file('qr9000.yml')

twitter = Twitter::Client.new(config[:authentication])

begin
	twitter.mentions(:since_id => config[:mostRecentMentionId]).each do |mention|
	
		# This is now the most recent mention inspected - don't try to reply again
		if mention.id > config[:mostRecentMentionId] then config[:mostRecentMentionId] = mention.id end
		
		# CHANGE BACK TO QR9000
		# Ignore mentions that don't match expected format…
		if !mention.text.match(/^@WheresThatSat\s+(.+)$/i) then next end
	
		# …but extract the content of any matches ($~ is the last MatchData)
		content = $~.captures[0]
	
		# (consider logging id/text/timestamp)
	
		# Generate QR code data based on content
		qr = RQRCode::QRCode.new(content)
	
		# Generate a PNG image of the QR code
		png = qr.to_img.resize(480, 480)
	
		# Post the QR image data in reply. Note that we force rgb output;
		# the default grayscale format gets mangled by twitter.
		reply = twitter.update_with_media(format("@%s ", mention.user.screen_name), png.to_datastream(:fast_rgb), :in_reply_to_status_id => mention.id)
		
		# do something with the reply response - like validate it.
		
	end
rescue Twitter::Error => e
	puts STDERR, e
end

# Update config file with mostRecentMentionId
File.open('qr9000.yml', 'w') {|file| YAML.dump(config, file)}
