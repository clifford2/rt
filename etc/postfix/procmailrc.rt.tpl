PATH=/bin:/usr/bin:/opt/rt5/bin
LOGFILE=/var/log/procmail/rt.log

#Messages >300000 characters proceed to recipient (unlikely to be spam)
:0w
* > 300000
| rt-mailgate --queue $QUEUE --action $ACTION --url {{url}}/

:0w
* ^X-RT-Loop-Prevention: {{domain}}
/dev/null

#Is it spam?
:0fw: spamassassin.lock
* < 300000
| spamc

#if the spam trigger is fired send to spam queue
:0w
* ^X-spam-Status: Yes
| rt-mailgate --queue spam --action correspond --url {{url}}/

#if the spam trigger is not fired then send to expected destination
:0w
| rt-mailgate --queue $QUEUE --action $ACTION --url {{url}}/
