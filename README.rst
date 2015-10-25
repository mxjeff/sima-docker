Description
===========

This image contains MPD, icecast2 and MPD_sima in order to serve an audio stream over http.

MPD is looking for music in /music (``music_directory`` option) and keeps its
dataset in /var/lib/mpd (options: ``playlist_directory``, ``{db,sticker,state}_file``).

TL;DR
=====

Build an image and run a container out of it.
Then point you MPD client to the run container::

    ./do build  # optional but then it'll fetch an image from hub.docker.com
    MUSIC=/pat/to/my/music/library ./do run

Configuration
=============

Running a container to play to content of your music library:

  - Audio stream available from http://127.0.0.1:8001
  - MPD available on 127.0.0.1:6601
  - Music directory: /path/to/my/music/library

Commands::
    LISTEN=127.0.0.1
    MUSIC="/path/to/my/music/library"
    OPTIONS="-p ${LISTEN}:8001:8000"
    OPTIONS="${OPTIONS} -p ${LISTEN}:6601:6600"
    OPTIONS="${OPTIONS} --volume ${MUSIC}:/music:ro"
    docker run ${OPTIONS} --detach=true --name sima kaliko/sima

To run mpd-sima with a specific configuration mount the file in the running container.
When /etc/mpd-sima.cfg is present in the container the default is to read it::

    OPTIONS="-P --detach=true"
    docker run -v ./my.config:/etc/mpd-sima.cfg ${OPTIONS} --name sima kaliko/sima
    # Discover ports with "docker port sima"

Mounting your music directory and saving MPD database in ${PWD}/data::

    OPTIONS="-P --detach=true"
    docker run -v ~/Music:/music:ro -v ${PWD}/data:/var/lib/mpd ${OPTIONS} --name sima kaliko/sima
    # Discover ports with "docker port sima"

Default option to run mpd-sima is "--log /var/log/mpd/mpd-sima.log".
Environment variable MPD_SIMA might be used to override default command line options::

    OPTIONS="-P --detach=true"
    docker run --env="MPD_SIMA=--log-level debug --log /var/log/mpd/mpd-sima.log" -v ${PWD}/log:/var/log/mpd ${OPTIONS} --name sima kaliko/sima
    # Discover ports with "docker port sima"
