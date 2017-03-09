FROM debian:latest
MAINTAINER Kaliko <kaliko@azylum.org>
ENV DEBIAN_FRONTEND noninteractive

ARG version
ENV VERSION ${version:-0.14.3}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends icecast2 mpd ncmpc mime-support virtualenv ncmpc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN install -d -o mpd /run/mpd
ADD mpd.conf /etc/mpd.conf

RUN virtualenv -p python3 /var/lib/mpd-sima
RUN bash -c "source /var/lib/mpd-sima/bin/activate && pip install MPD_sima==${VERSION}"

VOLUME /var/lib/mpd/

# expose icecast and mpd
EXPOSE 8000 6600

ENV MPD_HOST /run/mpd/socket

ADD start /usr/bin/start-sima
ADD mpd-sima /usr/bin/mpd-sima
ADD ncmpc-sima /usr/bin/ncmpc-sima
ADD mpd-sima.top.cfg mpd-sima.album.cfg /etc/

ENTRYPOINT ["/bin/sh", "/usr/bin/start-sima"]
