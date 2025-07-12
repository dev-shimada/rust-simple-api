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
if [ "${TARGETARCH}" = "arm64" ]; then
TARGET=aarch64-unknown-linux-musl
elif [ "${TARGETARCH}" = "amd64" ]; then
TARGET=x86_64-unknown-linux-musl
else
echo "Unsupported architecture: ${TARGETARCH}"
exit 1
fi
rustup target add ${TARGET}
cargo build --release --target ${TARGET}
mkdir -p /tmp/target
cp /workspace/target/${TARGET}/release/api /tmp/target/api

INSTALL_DIR=/tmp
VERSION=v0.1.1
curl --silent --location https://github.com/dev-shimada/http-health-probe/releases/download/${VERSION}/http-health-probe_${TARGETOS}_${TARGETARCH}.tar.gz | tar xvz -C ${INSTALL_DIR} --one-top-level=http-health-probe_${TARGETOS}_${TARGETARCH}
EOF


FROM gcr.io/distroless/base-debian12:latest
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY --chown=nonroot:nonroot --from=build /tmp/target/api /app/app
COPY --chown=nonroot:nonroot --from=build /tmp/http-health-probe_${TARGETOS}_${TARGETARCH}/http-health-probe /bin/http-health-probe
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s CMD ["/bin/http-health-probe", "--addr=:3000"]
EXPOSE 3000
USER nonroot:nonroot
ENTRYPOINT [ "/app/app" ]
