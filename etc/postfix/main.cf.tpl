myhostname = {{hostname}}
mydomain = {{domain}}
myorigin = $myhostname
inet_interfaces = all
mydestination = $myhostname
unknown_local_recipient_reject_code = 550
# relayhost = mail.{{domain}}
alias_maps = hash:/etc/postfix/aliases
alias_database = hash:/etc/postfix/aliases
recipient_delimiter = -