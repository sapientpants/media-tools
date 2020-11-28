FROM alpine:3.12.1

LABEL maintainer="Marc Tremblay <marc.tremblay@gmail.com>"

# See: https://trac.ffmpeg.org/ticket/6375 - 4.3.2+ should fix it
ENV JASPER_VERSION 1.900.1

# Update packages
RUN apk upgrade --no-cache

# Install runtime packages
RUN apk add --no-cache \
  boost \
  file \
  ffmpeg \
  ffmpegthumbnailer \
  gifsicle \
  imagemagick \
  jpeg \
  lcms2 \
  libpng \
  libsndfile \
  mediainfo

# Jasper - dcraw dependency
RUN apk add --no-cache --virtual .jaspermakedepends \
  build-base \
  && wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-${JASPER_VERSION}.zip \
  && unzip jasper-${JASPER_VERSION}.zip \
  && (cd jasper-${JASPER_VERSION} && ./configure && make && make install) \
  && rm -rf jasper-${JASPER_VERSION}* \
  && apk del -r --no-cache .jaspermakedepends

# dcraw
RUN mkdir /tmp/dcraw
COPY dcraw.c /tmp/dcraw/dcraw.c
RUN apk add --no-cache --virtual .dcrawmakedepends \
  build-base \
  jpeg-dev \
  lcms2-dev \
  && (cd /tmp/dcraw && gcc -o dcraw -O4 dcraw.c -lm -ljasper -ljpeg -llcms2 && cp dcraw /usr/local/bin) \
  && rm -rf /tmp/dcraw \
  && apk del -r --no-cache .dcrawmakedepends

# wav2png
RUN apk add --no-cache --virtual .wav2pngmakedepends \
  boost-dev \
  build-base \
  git \
  libpng-dev \
  libsndfile-dev \
  && git clone https://github.com/beschulz/wav2png.git \
  && (cd wav2png/dependencies/include && git fetch --all --tags --prune && git checkout tags/0.4 -b 0.4 && wget https://download.savannah.gnu.org/releases/pngpp/png++-0.2.7.tar.gz && tar zxvf png++-0.2.7.tar.gz && mv png++-0.2.7 png++ && sed -i -e 's/#error Byte-order could not be detected./#include <endian.h>/g' png++/config.hpp) && (cd wav2png/build && make && cp ../bin/Linux/wav2png /usr/local/bin) \
  && rm -rf wav2png \
  && apk del -r --no-cache .wav2pngmakedepends
