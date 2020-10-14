FROM rust:1.47.0 AS build

# Version numbers for all the crates we're going to install
ARG MDBOOK_VERSION="0.4.3"
ARG MDBOOK_LINKCHECK_VERSION="0.7.0"
ARG MDBOOK_TOC_VERSION="0.5.1"
ARG MDBOOK_OPEN_GIT_REPO_VERSION="0.0.2"

ENV CARGO_INSTALL_ROOT /usr/local/

RUN cargo install mdbook --vers ${MDBOOK_VERSION} --verbose
RUN apt-get update && apt-get install -y libssl-dev pkg-config && \
cargo install mdbook-linkcheck --vers ${MDBOOK_LINKCHECK_VERSION} --verbose
RUN cargo install mdbook-toc --vers ${MDBOOK_TOC_VERSION} --verbose
RUN cargo install mdbook-open-git-repo --vers ${MDBOOK_OPEN_GIT_REPO_VERSION} --verbose

# Create the final image
FROM ubuntu:20.04

LABEL maintainer="emt@magenta.dk"
ENV RUST_LOG info

# used when serving
EXPOSE 3000

COPY --from=build /usr/local/bin/mdbook* /bin/

WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/mdbook" ]
