# Dockerfile for running Best Practical's Request Tracker
# https://bestpractical.com/request-tracker
# Based on https://github.com/okfn/docker-rt.git
#
# Build with:
#   time docker build -t cliffordw/rt:5.0.0 . && docker tag cliffordw/rt:5.0.0 cliffordw/rt:latest

#-#-# BASE LAYER #-#-#
FROM docker.io/library/debian:buster AS base

# Environment
ENV LANG=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Install required packages
RUN apt-get -q -y update \
  && DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
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
  libemail-address-perl libemail-address-list-perl libhtml-formatexternal-perl libhtml-formattext-withlinks-perl libhtml-formattext-withlinks-andtables-perl libhtml-gumbo-perl libhtml-mason-perl libhtml-mason-psgihandler-perl libhtml-quoted-perl libhtml-rewriteattributes-perl libjavascript-minifier-perl libhtml-scrubber-perl \
  liblocale-maketext-fuzzy-perl liblocale-maketext-lexicon-perl libmodule-path-perl libmodule-versions-report-perl libnet-cidr-perl librole-basic-perl libscope-upper-perl libsymbol-global-name-perl libterm-readkey-perl libtime-parsedate-perl libtree-simple-perl \
  libencode-detect-perl libencode-hanextra-perl \
  libgd-perl libgd-graph-perl libgd-text-perl \
  libfile-which-perl \
  libjavascript-minifier-xs-perl \
  libtest-deep-perl libtest-exception-perl libtest-longstring-perl \
  libserver-starter-perl libparallel-prefork-perl \
  libtype-tiny-perl libtype-tiny-xs-perl \
  libmoox-handlesvia-perl libstring-shellquote-perl \
  nginx-light \
  postfix \
  procmail \
  razor \
  spamassassin \
  spawn-fcgi \
  netcat \
  && apt remove -y git gcc && apt autoremove -y \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log /usr/share/doc /usr/share/man


#-#-# BUILD LAYER #-#-#
FROM base AS build

# Install required packages
RUN apt-get -q -y update \
  && DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
  build-essential \
  git \
  cpanminus

# Set up environment
ENV PERL_MM_USE_DEFAULT 1
ENV PERL_MM_OPT "INSTALL_BASE=/usr/local"
ENV PERL5LIB="/usr/local/lib/perl5"
ENV HOME /root

# Autoconfigure cpan for "make fixdeps", and upgrade
RUN echo "Configure CPAN" \
  && echo q | /usr/bin/perl -MCPAN -e shell \
  && cpan install CPAN
# Install known cpan prereqs
RUN echo "Install CPAN modules" \
  && cpanm DBIx::SearchBuilder IPC::Run3 MIME::Entity Mozilla::CA Path::Dispatcher Plack::Handler::Starlet Regexp::Common Regexp::Common::net::CIDR Regexp::IPv6 GnuPG::Interface Text::Template \
  && rm -r /root/.cpanm

# Build RT
ENV RT rt-5.0.0
ENV RTSRC ${RT}.tar.gz
RUN mkdir /src
#ADD http://download.bestpractical.com/pub/rt/release/${RTSRC} /src/${RTSRC}
COPY ${RTSRC} /src/${RTSRC}
RUN echo "Build RT"; \
  tar -C /src -xzpf /src/${RTSRC} && \
  rm /src/${RTSRC} && \
  cd /src/${RT} && ./configure --with-db-type=mysql --enable-gpg --enable-gd --enable-graphviz && \
  make -C /src/${RT} fixdeps; \
  make -C /src/${RT} testdeps && \
  make -C /src/${RT} install


#-#-# FINAL LAYER #-#-#
FROM base AS run

# Copy build artifacts (PERL modules & RT) from build layer
ENV PERL5LIB="/usr/local/lib/perl5"
COPY --from=build /usr/local /usr/local
COPY --from=build /opt/rt5 /opt/rt5

# Test that we've installed all RT dependencies
RUN /opt/rt5/sbin/rt-test-dependencies

# Add system service config
ADD ./etc/nginx.conf /etc/nginx/nginx.conf
ADD ./etc/crontab.root /var/spool/cron/crontabs/root

# Configure Postfix
ADD ./etc/postfix /etc/postfix
ADD ./etc/logrotate.procmail /etc/logrotate.d/procmail
RUN echo "Configre postfix" \
  && chown -R root:root /etc/postfix \
  && newaliases \
  && mkdir -m 1777 /var/log/procmail \
  && cp -p /etc/services /var/spool/postfix/etc/services

# Configure RT
ADD ./scripts/ /usr/local/bin/
ADD ./RT_SiteConfig.pm /opt/rt5/etc/RT_SiteConfig.pm
RUN echo "Configure RT" \
  && chmod 0644 /opt/rt5/etc/RT_SiteConfig.pm \
  && mv /opt/rt5/var /data && ln -s /data /opt/rt5/var \
  && mkdir /var/log/rt5 /var/log/spamd
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]

RUN rm -rf /tmp/* /var/tmp/*

VOLUME ["/data"]
EXPOSE 25
EXPOSE 80
