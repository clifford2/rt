root:		{{email}}

MAILER-DAEMON:	postmaster
postmaster:	root
abuse:		root

backup:		/dev/null
bin:		/dev/null
daemon:		/dev/null
games:		/dev/null
gnats:		/dev/null
irc:		/dev/null
libuuid:	/dev/null
list:		/dev/null
lp:		/dev/null
mail:		/dev/null
man:		/dev/null
news:		/dev/null
nobody:		/dev/null
postfix:	/dev/null
postgres:	/dev/null
proxy:		/dev/null
sync:		/dev/null
sys:		/dev/null
uucp:		/dev/null
www-data:	/dev/null

rt:		"|/usr/bin/procmail -m ACTION=correspond QUEUE={{queue}} /etc/postfix/procmailrc.rt"
rt-comment:	"|/usr/bin/procmail -m ACTION=comment QUEUE={{queue}} /etc/postfix/procmailrc.rt"
