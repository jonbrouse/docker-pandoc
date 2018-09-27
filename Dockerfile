FROM alpine
# Most of this file comes from portown/alpine-pandoc
# https://github.com/portown/alpine-pandoc/blob/master/container/Dockerfile

ENV PANDOC_VERSION 2.3
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/archive/$PANDOC_VERSION.tar.gz
ENV PANDOC_DOWNLOAD_SHA512 69d8d427134c941415e8917a5c59a2aab70675cf2ca6bb056f2b8726ef612338a26de18d323e0ba8fb764a81383f700cbf025e38cf2248418a8b0f0dc9f80fee
ENV PANDOC_ROOT /usr/local/pandoc

RUN apk add --no-cache \
    gmp \
    libffi \
 && apk add --no-cache --virtual build-dependencies \
    --repository "http://nl.alpinelinux.org/alpine/edge/community" \
    ghc \
    cabal \
    linux-headers \
    musl-dev \
    zlib-dev \
    curl \
 && mkdir -p /pandoc-build && cd /pandoc-build \
 && curl -fsSL "$PANDOC_DOWNLOAD_URL" -o pandoc.tar.gz \
 && echo "$PANDOC_DOWNLOAD_SHA512  pandoc.tar.gz" | sha512sum -c - \
 && tar -xzf pandoc.tar.gz && rm -f pandoc.tar.gz \
 && ( cd pandoc-$PANDOC_VERSION && cabal update && cabal install --only-dependencies \
    && cabal configure --prefix=$PANDOC_ROOT \
    && cabal build \
    && cabal copy \
    && cd .. ) \
 && rm -Rf pandoc-$PANDOC_VERSION/ \
 && apk del --purge build-dependencies \
 && rm -Rf /root/.cabal/ /root/.ghc/ \
 && cd / && rm -Rf /pandoc-build

ENV PATH $PATH:$PANDOC_ROOT/bin

RUN apk add --no-cache --update textlive
