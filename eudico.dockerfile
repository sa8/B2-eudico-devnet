# Create builder container
FROM golang:1.17 as builder

# set BRANCH_FIL or COMMIT_HASH_FIL
ARG BRANCH_FIL=filecoin-project/eudico/tree/B2-bitcoin-checkpointing
ARG COMMIT_HASH_FIL=""
ARG REPO_FIL=https://github.com/filecoin-project/eudico
ARG NODEPATH=/lotus

ENV DEBIAN_FRONTEND=noninteractive

# Clone Eudico
RUN if [ -z "${BRANCH_FIL}" ] && [ -z "${COMMIT_HASH_FIL}" ]; then \
  		echo 'Error: Both BRANCH_FIL and COMMIT_HASH_FIL are empty'; \
  		exit 1; \
    fi

RUN if [ ! -z "${BRANCH_FIL}" ] && [ ! -z "${COMMIT_HASH_FIL}" ]; then \
		echo 'Error: Both BRANCH_FIL and COMMIT_HASH_FIL are set'; \
		exit 1; \
	fi


WORKDIR ${NODEPATH}
RUN git clone ${REPO_FIL} ${NODEPATH}

RUN if [ ! -z "${BRANCH_FIL}" ]; then \
        echo "Checking out to Eudico branch: ${BRANCH_FIL}"; \
  		git checkout ${BRANCH_FIL}; \
    fi

RUN if [ ! -z "${COMMIT_HASH_FIL}" ]; then \
		echo "Checking out to Lotus commit: ${COMMIT_HASH_FIL}"; \
		git checkout ${COMMIT_HASH_FIL}; \
	fi

# Install Eudico deps
RUN apt-get update && \
    apt-get install -yy apt-utils && \
    apt-get install -yy gcc git bzr jq pkg-config mesa-opencl-icd ocl-icd-opencl-dev hwloc libhwloc-dev

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

ENV RUSTFLAGS="-C target-cpu=native -g"
ENV FFI_BUILD_FROM_SOURCE=1

RUN make clean eudico

# Create final container
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ARG LOTUS_API_PORT=1234
EXPOSE 8000


# Install Lotus deps
RUN apt-get update && \
    apt-get install -yy apt-utils socat curl && \
    apt-get install -yy bzr jq pkg-config mesa-opencl-icd ocl-icd-opencl-dev wget libltdl7 libnuma1 hwloc libhwloc-dev tmux

# Install eudico
COPY --from=builder /lotus/eudico /usr/local/bin/
COPY --from=builder /lotus/data/ /eudico_data

# Create genesis file
#RUN eudico delegated genesis t1d2xrzcslx7xlbbylc5c3d5lvandqw4iwl6epxba gen.gen

# Copy genesis file
COPY gen.gen /gen.gen

# Copy key file
COPY key.key /key.key

# Copy startup script
COPY start_eudico.sh /start_eudico.sh

ENTRYPOINT ["/start_eudico.sh"]

