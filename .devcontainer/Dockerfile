FROM rust:1.85-bookworm AS vscode

WORKDIR /workspace

RUN <<EOF
apt-get update
apt-get install -y git vim curl
rustup component add rustfmt rust-analyzer rust-docs
EOF
COPY . .

# CMD ["go", "run", "main.go"]
