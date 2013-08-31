#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'
require 'rqrcode_png'
require 'yaml'
require 'logger'
require 'tempfile'

config = YAML.load_file('qr9000.yml')
logger = Logger.new('qr9000.log', 2, 1024000)
logger.level = Logger::INFO


begin
	twitter = Twitter::Client.new(config[:authentication])
	mentions = twitter.mentions(:since_id => config[:mostRecentMentionId], :include_entities => true)
rescue Twitter::Error => err
	logger.fatal {err}
	exit
end

mentions.each do |mention|
	
	# This is now the most recent mention inspected - don't try to reply again
	if mention.id > config[:mostRecentMentionId] then config[:mostRecentMentionId] = mention.id end
	
	# Ignore mentions that don't match expected format…
	if !mention.text.match(/^(@QR9000\s+)(.+)$/i) then next end

	# …but extract the content of any matches ($~ is the last MatchData)
	offset = $~.captures[0].length
	tweet = $~.captures[1]
	
	# content is a copy of tweet, but with t.co URLs expanded to their original form.
	laststart = 0
	content = ''
	mention.urls.each do |url|
		if url.indices[0]-1 > offset then content += tweet[laststart..(url.indices[0]-1-offset)] end
		content += url.expanded_url
		laststart = url.indices[1]-offset
	end
	content += tweet[laststart..-1]
		
	# Generate the QR 
	size = 4
	begin
		qr = RQRCode::QRCode.new(content, :size => size)
	rescue RQRCode::QRCodeRunTimeError => qerr

		# Content too big for size. Let error stand if already largest size.
		if size == 40 then
			logger.error {qerr}
			next
		end
		
		# Otherwise, increase the size and try again.
		size += 1
		retry
		
	end

	# Generate a PNG image of the QR code
	png = qr.to_img.resize(480, 480)
	tmpfile = Tempfile.new("qr#{mention.id}")
	png.write(tmpfile)
	
	# Format the response text, including as much of the content as we have to quote
	maxQuoteLength = 111 - mention.user.screen_name.length
	response = format("@%s \"%s\": ", mention.user.screen_name, content[0..(maxQuoteLength-1)])

	# Post the QR code image in reply; rgb format explicit (default grayscale PNG appears to confuse Twitter)
	begin
		reply = twitter.update_with_media(response, tmpfile.open, :in_reply_to_status_id => mention.id)
	rescue Twitter::Error => err
		logger.error {err}
		next
	end
	
	logger.info {"#{mention.user.screen_name}, #{mention.id}, #{reply.id}, #{size}, \"#{content}\""}
	
end

# Overwrite config file to update mostRecentMentionId.
File.open('qr9000.yml', 'w') {|file| YAML.dump(config, file)}
