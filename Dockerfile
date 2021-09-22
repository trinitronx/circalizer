FROM python:3-alpine3.14

RUN apk update \
        && apk add --no-cache bash build-base cmake autoconf g++ gcc make flex bison wget git tar
RUN apk add --no-cache shadow util-linux procps openrc openblas-dev lapack-dev libffi-dev \
            jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev \
            tcl-dev harfbuzz-dev fribidi-dev llvm11-dev \
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

# Install pyarrow
# Source: https://gist.github.com/bskaggs/fc3c8d0d553be54e2645616236fdc8c6
RUN pip3 install --no-cache-dir six pytest numpy cython
RUN pip3 install --no-cache-dir pandas


ARG ARROW_VERSION=5.0.0
ARG ARROW_SHA1=d70a969524902068e5b5b5b628bc117249351ccd
ARG ARROW_BUILD_TYPE=release

ENV ARROW_HOME=/usr/local \
    PARQUET_HOME=/usr/local

#Download and build apache-arrow
RUN mkdir /arrow \
    && wget -q https://github.com/apache/arrow/archive/apache-arrow-${ARROW_VERSION}.tar.gz -O /tmp/apache-arrow.tar.gz \
    && echo "${ARROW_SHA1} *apache-arrow.tar.gz" | sha1sum /tmp/apache-arrow.tar.gz \
    && tar -xvf /tmp/apache-arrow.tar.gz -C /arrow --strip-components 1 \
    && mkdir -p /arrow/cpp/build \
    && cd /arrow/cpp/build \
    && cmake -DCMAKE_BUILD_TYPE=$ARROW_BUILD_TYPE \
        -DOPENSSL_ROOT_DIR=/usr/local/ssl \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
        -DARROW_WITH_BZ2=ON \
        -DARROW_WITH_ZLIB=ON \
        -DARROW_WITH_ZSTD=ON \
        -DARROW_WITH_LZ4=ON \
        -DARROW_WITH_SNAPPY=ON \
        -DARROW_PARQUET=ON \
        -DARROW_PYTHON=ON \
        -DARROW_PLASMA=ON \
        -DARROW_BUILD_TESTS=OFF \
        .. \
    && make -j$(nproc) \
    && make install \
    && cd /arrow/python \
    && python setup.py build_ext --build-type=$ARROW_BUILD_TYPE --with-parquet \
    && python setup.py install \
    && rm -rf /arrow /tmp/apache-arrow.tar.gz

ARG CONTAINER_SOURCE_PATH=${CONTAINER_SOURCE_PATH:-/src/circalizer}

COPY build-aux ${CONTAINER_SOURCE_PATH}/build-aux
COPY Makefile ${CONTAINER_SOURCE_PATH}/
WORKDIR ${CONTAINER_SOURCE_PATH}

# Install the rest of python packages for the jupyter notebook
RUN make jupyter-depends


RUN adduser --disabled-password --home ${CONTAINER_SOURCE_PATH} jupyter && \
    addgroup jupyter jupyter
RUN cp -r  /root/.local ${CONTAINER_SOURCE_PATH}/ && \
    chown -R jupyter:jupyter ${CONTAINER_SOURCE_PATH}/.local

# Finally, copy the rest in and setup jupyter for run
COPY . ${CONTAINER_SOURCE_PATH}

USER jupyter
ENV PATH=${CONTAINER_SOURCE_PATH}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

EXPOSE 8888/tcp
VOLUME ["${CONTAINER_SOURCE_PATH}/code", "${CONTAINER_SOURCE_PATH}/data"]
ENTRYPOINT ["${CONTAINER_SOURCE_PATH}/bin/start_jupyter_notebook.sh"]
