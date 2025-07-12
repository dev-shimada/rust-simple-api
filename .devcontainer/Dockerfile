FROM rust:1.85-bookworm AS vscode

WORKDIR /workspace

RUN <<EOF
apt-get update
apt-get install -y git vim curl
rustup component add rustfmt rust-analyzer rust-docs
rustup target add aarch64-unknown-linux-musl x86_64-unknown-linux-musl
EOF
