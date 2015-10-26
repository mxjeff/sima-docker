Description
===========

This image contains MPD, icecast2 and MPD_sima in order to serve an audio stream over http.

MPD is looking for music in */music* (``music_directory`` option) and keeps its
dataset in */var/lib/mpd* (options: ``playlist_directory``, ``{db,sticker,state}_file``).

tl;dr
=====

::

    MUSIC=/pat/to/my/music/library ./do run

Then point your MPD client to ``127.0.0.1:6601``. Audio stream from http://127.0.0.1:8001/sima.ogg .

Configuration
=============

Running a container to play to content of your music library:

::

    LISTEN=127.0.0.1
    MUSIC="/path/to/my/music/library"
    OPTIONS="-p ${LISTEN}:8001:8000"
    OPTIONS="${OPTIONS} -p ${LISTEN}:6601:6600"
    OPTIONS="${OPTIONS} --volume ${MUSIC}:/music:ro"
    docker run ${OPTIONS} --name sima kaliko/sima

The container ``sima`` is running with the following configuration:

  - Music directory: /path/to/my/music/library
  - Audio stream available from http://127.0.0.1:8001
  - MPD available on 127.0.0.1:6601

It is quite useful to save MPD database once it has read all your Music library.
In order to save it for later use with another container use a volume.

Here is an example on how to mount your music directory and save MPD database in ${PWD}/data:

::

    mkdir -p ${PWD}/data
    OPTIONS="-P --detach=true"
    OPTIONS="${OPTIONS} -v ~/Music:/music:ro -v ${PWD}/data:/var/lib/mpd"
    docker run ${OPTIONS} --name sima kaliko/sima
    # Discover ports with "docker port sima"

Default option to run mpd-sima is "--log /var/log/mpd/mpd-sima.log".

Environment variable ``MPD_SIMA`` can be set to override default command line options.

This is especially useful to launch a container with preloaded configuration files:

  - ``/etc/mpd-sima.album.cfg`` : Album mode queuing method
  - ``/etc/mpd-sima.top.cfg`` : Top tracks queuing method

Running the album mode::

    OPTIONS="-P --detach=true"
    OPTIONS="${OPTIONS} -v ~/Music:/music:ro -v ${PWD}/data:/var/lib/mpd"
    docker run --env="MPD_SIMA=--config /etc/mpd-sima.album.cfg" ${OPTIONS} --name sima kaliko/sima
    # Discover ports with "docker port sima"


To run mpd-sima with your own configuration, mount the file in the running container.
When /etc/mpd-sima.cfg is present in the container the default is to read it.

::

    OPTIONS="-P --detach=true"
    OPTIONS="${OPTIONS} -v ~/Music:/music:ro -v ${PWD}/data:/var/lib/mpd"
    docker run -v ./my.config:/etc/mpd-sima.cfg ${OPTIONS} --name sima kaliko/sima
    # Discover ports with "docker port sima"

