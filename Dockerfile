FROM ghcr.io/gleam-lang/gleam:v1.9.1-erlang-alpine

# Add project code
COPY . /build/

# Compile the project and copy assets
RUN mkdir -p /app/build && cd /app/build \
    && gleam export erlang-shipment \
    && mv erlang-shipment /app \
    && mkdir -p /app/src /app/public \
    && cp -r src/* /app/src/ \
    && cp -r public/* /app/public/ \
    && cp -r .env /app/ \
    && rm -r /app/build

# Run the server
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
