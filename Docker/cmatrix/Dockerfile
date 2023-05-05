# Build Container Image

FROM alpine as cmatrixbuilder

#MAINTAINER Kishore Kumar<hello@kishorekumar.today>

WORKDIR cmatrix
RUN  apk update --no-cache && \
     apk add git autoconf automake alpine-sdk ncurses-dev ncurses-static && \
     git clone https://github.com/abishekvashok/cmatrix . && \
     autoreconf -i && \
     mkdir -p /usr/lib/kbd/consolefonts /usr/share/consolefonts /usr/share/fonts/misc /usr/share/X11/fonts/misc /usr/X11R6/lib/X11/fonts/misc && \
     ./configure LDFLAGS="-static" && \
     make

FROM alpine
#MAINTAINER Kishore Kumar<hello@kishorekumar.today>

LABEL org.opencontainers.image.authors="Kishore Kumar" \
      org.opencontainers.image.description="Cmatrix Docker Iamge Build Repo Credits: https://github.com/abhishekvashok/cmatrix"

RUN apk update --no-cache  && \
    apk add ncurses-terminfo-base && \
    adduser -g "Kishore Kumar" -s /usr/sbin/nologin -D -H kishore

USER kishore

COPY --from=cmatrixbuilder /cmatrix/cmatrix /cmatrix

ENTRYPOINT ["./cmatrix"]
CMD ["-b"]