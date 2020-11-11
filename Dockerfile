FROM rust:1.47.0 AS build

ENV CARGO_INSTALL_ROOT /usr/local/

# Get SSL and allow linking to it (needed by reqwest used by linkcheck)
RUN apt-get update && apt-get install -y libssl-dev pkg-config

# Temporarily install from latest commit on master until 0.7.2 is released
RUN cargo install --git https://github.com/Michael-F-Bryan/mdbook-linkcheck --verbose
RUN cargo install mdbook-toc --vers 0.5.1 --verbose
RUN cargo install mdbook-open-git-repo --vers 0.0.2 --verbose
RUN cargo install mdbook-mermaid --vers 0.6.1 --verbose

# Patch in custom highlight.js before building mdbook
COPY ./highlight.min.js /js/
RUN \
  git clone --depth 1 --branch v0.4.4 https://github.com/rust-lang/mdBook.git && \
  cp /js/highlight.min.js mdBook/src/theme/highlight.js && \
  cd mdBook && \
  cargo install --path .

# Create the final image
FROM ubuntu:20.04

LABEL maintainer="emt@magenta.dk"
ENV RUST_LOG info

# used when serving
EXPOSE 3000

# Ensure reqwest (HTTP library powering linkcheck) has certs available
RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates \
&& apt-get clean && rm -rf "/var/lib/apt/lists/*" "/tmp/*" "/var/tmp/*" "/usr/share/man/??" "/usr/share/man/??_*"

COPY --from=build /usr/local/bin/mdbook* /bin/

WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/mdbook" ]
