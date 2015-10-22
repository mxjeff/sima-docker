FROM debian:latest
MAINTAINER Kaliko <kaliko@azylum.org>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && apt-get -y upgrade && apt-get install -y --no-install-recommends icecast2 mpd mime-support virtualenv
RUN apt-get clean
RUN usermod --shell /bin/dash icecast2
RUN usermod --shell /bin/dash mpd
ADD mpd.conf /etc/mpd.conf

RUN virtualenv -p python3 /var/lib/mpd-sima
RUN bash -c "source /var/lib/mpd-sima/bin/activate && pip install MPD_sima"

VOLUME /var/lib/mpd/music/

# expose icecast and mpd
EXPOSE 8000 6600

ADD start /usr/bin/start-sima
ADD sima /usr/bin/sima

ENTRYPOINT ["/bin/sh", "/usr/bin/start-sima"]
