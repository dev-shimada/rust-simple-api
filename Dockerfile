FROM --platform=$BUILDPLATFORM rust:1.85-bookworm AS build
ARG BUILDPLATFORM
WORKDIR /workspace
RUN <<EOF
apt-get update
apt-get install -y lld
rm -rf /var/lib/apt/lists/*
EOF

COPY . .
RUN <<EOF
cargo build --release --target aarch64-unknown-linux-musl
EOF


FROM --platform=$BUILDPLATFORM gcr.io/distroless/base-debian12:latest
ARG BUILDPLATFORM
WORKDIR /app
COPY --chown=nonroot:nonroot --from=build /workspace/target/aarch64-unknown-linux-musl/release/api /app/app
COPY --chown=nonroot:nonroot http-health-probe /bin/http-health-probe
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s CMD ["/bin/http-health-probe", "--addr=http://localhost:3000"]
EXPOSE 3000
USER nonroot:nonroot
ENTRYPOINT [ "/app/app" ]
