FROM rust:1.47.0 AS build

ENV CARGO_INSTALL_ROOT /usr/local/

# Get SSL and allow linking to it (needed by reqwest used by linkcheck)
RUN apt-get update && apt-get install -y libssl-dev pkg-config

RUN cargo install mdbook --vers 0.4.3 --verbose
RUN cargo install mdbook-linkcheck --vers 0.7.1 --verbose
RUN cargo install mdbook-toc --vers 0.5.1 --verbose
RUN cargo install mdbook-open-git-repo --vers 0.0.2 --verbose

# Create the final image
FROM ubuntu:20.04

LABEL maintainer="emt@magenta.dk"
ENV RUST_LOG info

# used when serving
EXPOSE 3000

# Ensure reqwest (HTTP library powering linkcheck) has certs available
RUN apt-get update && apt-get install -y ca-certificates

COPY --from=build /usr/local/bin/mdbook* /bin/

WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/mdbook" ]
