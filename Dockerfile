FROM rust:1.85-bookworm AS build
ARG TARGETOS
ARG TARGETARCH
WORKDIR /workspace
RUN <<EOF
apt-get update
apt-get install -y lld
rm -rf /var/lib/apt/lists/*
EOF
COPY . .
RUN <<EOF
cargo build --release --target aarch64-unknown-linux-musl
INSTALL_DIR=/tmp
VERSION=v0.1.1
curl --silent --location https://github.com/dev-shimada/http-health-probe/releases/download/${VERSION}/http-health-probe_${TARGETOS}_${TARGETARCH}.tar.gz | tar xvz -C ${INSTALL_DIR} --one-top-level=http-health-probe_${TARGETOS}_${TARGETARCH}
EOF


FROM gcr.io/distroless/base-debian12:latest
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY --chown=nonroot:nonroot --from=build /workspace/target/aarch64-unknown-linux-musl/release/api /app/app
COPY --chown=nonroot:nonroot --from=build /tmp/http-health-probe_${TARGETOS}_${TARGETARCH}/http-health-probe /bin/http-health-probe
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s CMD ["/bin/http-health-probe", "--addr=:3000"]
EXPOSE 3000
USER nonroot:nonroot
ENTRYPOINT [ "/app/app" ]
