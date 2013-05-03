QR9000
------

[![QR9000 Icon](https://raw.github.com/anoved/QR9000/master/Icon/QR9000.png)](https://github.com/anoved/QR9000/tree/master/Icon)

*My cousin HAL claimed to be foolproof and incapable of error. I just convert your tweets to QR codes.*

This is a Ruby script used to control a Twitter account, [@QR9000](https://twitter.com/QR9000), that replies to mentions with the content of the mention encoded as a [QR code](https://twitter.com/QR9000). Any URLs in the encoded text are expanded to their original non-t.co form. QR codes are formatted with "Level H" (high) error correction and posted as image attachments to QR9000's replies. The script runs periodically as a `cron` job.

Requirements:
-------------

Both of these modules (and their prerequisites) can be installed with `gem`.

- <https://github.com/sferik/twitter>
- <https://github.com/DCarper/rqrcode_png>

Config File Format:
-------------------

The script expects to find a YAML configuration file named `qr9000.yml` with the following keys:

	--- 
	:authentication: 
	  :consumer_key: 
	  :consumer_secret: 
	  :oauth_token: 
	  :oauth_token_secret: 
	:mostRecentMentionId: 

The `authentication` keys should be set to the values associated with your Twitter API account (see some examples [here](https://github.com/sferik/twitter#configuration)). The `mostRecentMentionId` key records the id of the latest tweet directed at the bot so that old messages may be ignored. This value is updated by the script.
