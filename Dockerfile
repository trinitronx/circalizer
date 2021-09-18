FROM python:3-alpine

COPY . /src/circalizer
WORKDIR /src/circalizer

RUN apk update \
        && apk add bash build-base cmake autoconf flex bison wget git tar
RUN apk add shadow util-linux procps openrc openblas-dev lapack-dev libffi-dev \
            jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev \
            tcl-dev harfbuzz-dev fribidi-dev llvm10-dev \
            boost-dev libressl-dev

RUN pip3 install --upgrade pip

RUN wget -O/tmp/init.sh https://sh.rustup.rs \
        && \
    sh /tmp/init.sh -y \
        && \
    rm /tmp/init.sh

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup install nightly \
        && \
    rustup default nightly

ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV ARROW_HOME=/usr/local \
    PARQUET_HOME=/usr/local

RUN make jupyter-depends

VOLUME ["/src/circalizer/code"]
ENTRYPOINT ["/src/circalizer/bin/start_jupyter_notebook.sh"]
