# syntax=docker/dockerfile:1

# ---- Build stage: full Rust toolchain ----
FROM rust:1-slim-bookworm AS builder
WORKDIR /app

# Build dependencies first with a stub main, so this layer stays cached
# until Cargo.toml or Cargo.lock changes.
COPY Cargo.toml Cargo.lock ./
RUN mkdir src \
    && echo 'fn main() {}' > src/main.rs \
    && cargo build --release --locked

# Now build the real sources. `touch` makes cargo see main.rs as newer
# than the stub build above.
COPY src ./src
RUN touch src/main.rs && cargo build --release --locked

# ---- Runtime stage: glibc only, no shell, non-root user ----
# Debian release must match the builder (bookworm == debian12).
FROM gcr.io/distroless/cc-debian12:nonroot
COPY --from=builder /app/target/release/r-echo /r-echo
EXPOSE 3000
ENTRYPOINT ["/r-echo"]
