# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# COMPILE PANDOC FROM SOURCE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM alpine as compile-step

ENV PANDOC_VERSION 2.3
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/archive/$PANDOC_VERSION.tar.gz
ENV PANDOC_DOWNLOAD_SHA512 69d8d427134c941415e8917a5c59a2aab70675cf2ca6bb056f2b8726ef612338a26de18d323e0ba8fb764a81383f700cbf025e38cf2248418a8b0f0dc9f80fee
ENV PANDOC_ROOT /usr/local/pandoc

WORKDIR /pandoc-build

ENV REQUIRED_PACKAGES="cmark gmp libffi pcre zlib"
ENV BUILD_PACKAGES="cabal curl ghc gmp-dev linux-headers musl-dev zlib-dev"

RUN apk add --no-cache --virtual build-dependencies \
                       --repository "http://nl.alpinelinux.org/alpine/edge/community" \
                       $BUILD_PACKAGES $REQUIRED_PACKAGES && \
    curl -fsSL "$PANDOC_DOWNLOAD_URL" -o pandoc.tar.gz && \
    echo "$PANDOC_DOWNLOAD_SHA512  pandoc.tar.gz" | sha512sum -c - && \
    tar --strip-components=1 -zxvf pandoc.tar.gz && \
    cabal sandbox init && \
    cabal update && \
    cabal install hsb2hs && \
    cabal install --only-dependencies && \
    cabal configure -v --prefix=$PANDOC_ROOT && \
    cabal build --verbose=2 && \
    cabal copy

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BUILD PANDOC IMAGE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM alpine

ENV PANDOC_ROOT /usr/local/pandoc
ENV PATH $PATH:$PANDOC_ROOT/bin

COPY --from=compile-step $PANDOC_ROOT $PANDOC_ROOT

ENV REQUIRED_PACKAGES="cmark gmp libffi pcre texlive-xetex zlib"
ENV OPTIONAL_PACKAGES="texlive-full texmf-dist"

RUN apk add --no-cache --update $REQUIRED_PACKAGES 

#RUN apk add --no-cache --update $OPTIONAL_PACKAGES && \
#    wget http://mirrors.ctan.org/macros/latex/contrib/acrotex.zip && \
#    unzip acrotex.zip -d /usr/share/texmf-dist/tex/latex/ && \
#    rm acrotex.zip

WORKDIR /pandoc

ENTRYPOINT [ "/usr/local/pandoc/bin/pandoc" ]
