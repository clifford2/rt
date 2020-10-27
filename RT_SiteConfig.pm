use utf8;

# Any configuration directives you include  here will override
# RT's default configuration file, RT_Config.pm
#
# To include a directive here, just copy the equivalent statement
# from RT_Config.pm and change the value. We've included a single
# sample value below.
#
# If this file includes non-ASCII characters, it must be encoded in
# UTF-8.
#
# This file is actually a perl module, so you can include valid
# perl code, as well.
#
# The converse is also true, if this file isn't valid perl, you're
# going to run into trouble. To check your SiteConfig file, use
# this command:
#
#   perl -c /opt/rt5/etc/RT_SiteConfig.pm
#
# You must restart your webserver after making changes to this file.
#

# You may also split settings into separate files under the etc/RT_SiteConfig.d/
# directory.  All files ending in ".pm" will be parsed, in alphabetical order,
# after this file is loaded.

# You must install Plugins on your own, this is only an example
# of the correct syntax to use when activating them:
#     Plugin( "RT::Authen::ExternalAuth" );

Set( $rtname, $ENV{RT_NAME} || "example.com" );
Set( $Organisation, $ENV{RT_ORG} || "example.com" );
Set( $WebDomain, $ENV{WEB_DOMAIN} || "localhost" );
Set( $WebPort, $ENV{WEB_PORT} || 80 );
if (defined($ENV{WEB_BASEURL})) {
	Set( $WebBaseURL, $ENV{WEB_BASEURL} );
}
Set( $LogToSTDERR, $ENV{LOG_LEVEL} || "info" );
Set( $Timezone, $ENV{TIMEZONE} || "UTC" );

Set( $DatabaseType, "mysql" );
Set( $DatabaseHost, $ENV{DATABASE_HOST} || "localhost" );
Set( $DatabasePort, $ENV{DATABASE_PORT} || 3306 );
Set( $DatabaseName, $ENV{DATABASE_NAME} || "rtdb" );
Set( $DatabaseUser, $ENV{DATABASE_USER} || "rtuser" );
Set( $DatabasePassword, $ENV{DATABASE_PASSWORD} || "rtpass" );

if (defined($ENV{'EMAIL_ADDRESS'})) {
	Set($CorrespondAddress , $ENV{'EMAIL_ADDRESS'});
	Set($CommentAddress , $ENV{'EMAIL_ADDRESS'});
}

# GnuPG support requires extra work downstream to enable
Set( %GnuPG, Enable => 0 );

# Explicitly set $HTMLFormatter
Set( $HTMLFormatter, "/usr/bin/w3m" );

# For MySQL ACLs, allow access from any other container
Set( $DatabaseRTHost, '%' );

#Set( @MailPlugins, qw(Auth::MailFrom Filter::TakeAction) );

Set( %FullTextSearch,
    Enable     => 1,
    Indexed    => 1,
    Table      => 'AttachmentsIndex',
);

# This fixes "Undefined subroutine &RT::REST2::PSGIWrap" error
Plugin("RT::REST2");

1;
