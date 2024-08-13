# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG parent_image

FROM gcr.io/fuzzbench/base-image AS base-image

FROM $parent_image

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        python3-dev \
        python3-setuptools \
        automake \
        cmake \
        git \
        flex \
        bison \
        libglib2.0-dev \
        libpixman-1-dev \
        cargo \
        libgtk-3-dev \
        # for QEMU mode
        ninja-build \
        gcc-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-plugin-dev \
        libstdc++-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-dev 


COPY AFLplusplus /afl


RUN rm -rf /usr/local/bin/python3.8* /usr/local/bin/pip3 /usr/local/lib/python3.8 \
    /usr/local/include/python3.8 /usr/local/lib/python3.8/site-packages

ENV PYTHON_VERSION 3.10.8
RUN cd /tmp/ && \
    curl -O https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz && \
    tar -xvf Python-$PYTHON_VERSION.tar.xz > /dev/null && \
    cd Python-$PYTHON_VERSION && \
    ./configure \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --enable-shared \
        > /dev/null && \
    make -j install > /dev/null && \
    ldconfig && \
    rm -r /tmp/Python-$PYTHON_VERSION.tar.xz /tmp/Python-$PYTHON_VERSION && \
    rm -f /usr/local/bin/python && \
    ln -s /usr/local/bin/python3 /usr/local/bin/python && \
    rm -f /usr/local/bin/pip && \
    ln -s /usr/local/bin/pip3 /usr/local/bin/pip

RUN ldconfig

# Build without Python support as we don't need it.
# Set AFL_NO_X86 to skip flaky tests.
RUN cd /afl && \
    unset CFLAGS CXXFLAGS && \
    export CC=clang AFL_NO_X86=1 && \
    make distrib && \
    cp utils/aflpp_driver/libAFLDriver.a /
