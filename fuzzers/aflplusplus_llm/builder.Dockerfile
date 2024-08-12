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

# following steps in C:\Users\sd157\Documents\GitHub\fuzzbench_l1nna\docker\benchmark-builder\Dockerfile
# to copy python 3.10 before compiling afl

RUN rm -rf /usr/local/bin/python3.8* /usr/local/bin/pip3 /usr/local/lib/python3.8 \
    /usr/local/include/python3.8 /usr/local/lib/python3.8/site-packages

# Copy latest python3 from base-image into local.
COPY --from=base-image /usr/local/bin/python3* /usr/local/bin/
COPY --from=base-image /usr/local/bin/pip3* /usr/local/bin/
COPY --from=base-image /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=base-image /usr/local/include/python3.10 /usr/local/include/python3.10
COPY --from=base-image /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

RUN python3 --version


COPY AFLplusplus /afl

# Download afl++.
# RUN cd /afl && \
#     git checkout 56d5aa3101945e81519a3fac8783d0d8fad82779 || \
#     true

# Build without Python support as we don't need it.
# Set AFL_NO_X86 to skip flaky tests.
RUN cd /afl && \
    unset CFLAGS CXXFLAGS && \
    export CC=clang AFL_NO_X86=1 && \
    # export AFL_CUSTOM_MUTATOR_ONLY=1 && \
    # AFL_CUSTOM_MUTATOR_LIBRARY=custom_mutators/aflpp \
    # PYTHON_INCLUDE=/ 
    make distrib && \
    cp utils/aflpp_driver/libAFLDriver.a /
