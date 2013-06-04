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

Log File Format:
----------------

The script maintains an activity log in a file named `qr9000.log`. The maximum size of the log file is 1 MB and up to two old logs will be retained before deletion. The format of the log entries begins with the [default timestamp and severity label](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html#label-Format), followed by the mention user, the tweet ID of the mention, the tweet ID of QR9000's reply, the size ("version") of the generated QR code, and the content of the mention that is encoded in the QR code. An example: 

	I, [2013-05-04T15:50:49.073760 #94809]  INFO -- : anoved, 330771488808501248, 330771512967716864, 4, "May the 4th be with you!"

License
-------

QR9000's components are freely distributed under an open source [MIT License](http://opensource.org/licenses/MIT):

> Copyright (c) 2013 Jim DeVona
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
