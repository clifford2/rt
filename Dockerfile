# Dockerfile for running Best Practical's Request Tracker
# https://bestpractical.com/request-tracker
# Based on https://github.com/okfn/docker-rt.git
#
# Build with:
#   docker build -t cliffordw/rt:5.0.0 . && docker tag cliffordw/rt:5.0.0 cliffordw/rt:latest

FROM docker.io/library/debian:buster

# Install required packages
RUN apt-get -q -y update \
  && DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
  build-essential \
  cpanminus \
  git \
  gnupg \
  graphviz \
  perl-modules \
  libgraphviz-perl \
  libdbd-mariadb-perl \
  libdbd-mysql-perl \
  libdbd-sqlite3-perl \
  libcrypt-x509-perl \
  libfcgi-perl \
  libperlio-eol-perl \
  libjson-perl \
  libapache-session-perl \
  libmime-types-perl \
  libmoose-perl libmoosex-nonmoose-perl libmoosex-role-parameterized-perl \
  libtext-password-pronounceable-perl libtext-wikiformat-perl libtext-quoted-perl libtext-wrapper-perl \
  libxml-rss-perl \
  libuniversal-require-perl \
  libweb-machine-perl \
  libbusiness-hours-perl libcss-minifier-xs-perl libcss-squish-perl libclone-perl libconvert-color-perl libcrypt-eksblowfish-perl libdata-ical-perl libdata-guid-perl libdata-page-pageset-perl libdate-extract-perl libdate-manip-perl libdatetime-format-natural-perl \
  libemail-address-perl libemail-address-list-perl libencode-detect-perl libencode-hanextra-perl libhtml-formatexternal-perl libhtml-formattext-withlinks-perl libhtml-formattext-withlinks-andtables-perl libhtml-gumbo-perl libhtml-mason-perl libhtml-mason-psgihandler-perl libhtml-quoted-perl libhtml-rewriteattributes-perl libjavascript-minifier-perl libhtml-scrubber-perl \
  liblocale-maketext-fuzzy-perl liblocale-maketext-lexicon-perl libmodule-path-perl libmodule-versions-report-perl libnet-cidr-perl librole-basic-perl libscope-upper-perl libsymbol-global-name-perl libterm-readkey-perl libtime-parsedate-perl libtree-simple-perl \
  libgd-perl libgd-graph-perl libgd-text-perl \
  libfile-which-perl \
  libjavascript-minifier-xs-perl \
  libtest-deep-perl libtest-exception-perl libtest-longstring-perl \
  libserver-starter-perl libparallel-prefork-perl \
  libtype-tiny-perl libtype-tiny-xs-perl \
  nginx-light \
  postfix \
  procmail \
  razor \
  spamassassin \
  spawn-fcgi

# Set up environment
ENV PERL_MM_USE_DEFAULT 1
ENV HOME /root
ENV RT rt-5.0.0
ENV RTSRC ${RT}.tar.gz

# Autoconfigure cpan
RUN echo q | /usr/bin/perl -MCPAN -e shell
# Install known cpan prereqs
RUN cpanm DBIx::SearchBuilder IPC::Run3 MIME::Entity Mozilla::CA Path::Dispatcher Plack::Handler::Starlet Regexp::Common Regexp::Common::net::CIDR Regexp::IPv6 GnuPG::Interface

# Install RT
RUN mkdir /src
#ADD http://download.bestpractical.com/pub/rt/release/${RTSRC} /src/${RTSRC}
COPY ${RTSRC} /src/${RTSRC}
RUN tar -C /src -xzpvf /src/${RTSRC}
#RUN ln -s /src/${RT} /src/rt

RUN cd /src/${RT} && ./configure --with-db-type=mysql --enable-gpg --enable-gd --enable-graphviz
RUN make -C /src/${RT} fixdeps
RUN make -C /src/${RT} testdeps
RUN make -C /src/${RT} install

# Add system service config
ADD ./etc/nginx.conf /etc/nginx/nginx.conf
ADD ./etc/crontab.root /var/spool/cron/crontabs/root

# Configure Postfix
ADD ./etc/postfix /etc/postfix
ADD ./etc/logrotate.procmail /etc/logrotate.d/procmail
RUN echo "Configre postfix" \
  && chown -R root:root /etc/postfix \
  && newaliases \
  && mkdir -m 1777 /var/log/procmail

# Install netcat - fixme: move to other installs
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install netcat

# Configure RT
ADD ./scripts/ /usr/local/bin/
ADD ./RT_SiteConfig.pm /opt/rt5/etc/RT_SiteConfig.pm
RUN echo "Configure RT" \
  && chmod 0644 /opt/rt5/etc/RT_SiteConfig.pm \
  && mv /opt/rt5/var /data && ln -s /data /opt/rt5/var \
  && mkdir /var/log/rt5 /var/log/spamd
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]

VOLUME ["/data"]
EXPOSE 25
EXPOSE 80

RUN apt-get clean && rm -rf /src/${RTSRC} /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log