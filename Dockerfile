FROM ghcr.io/gleam-lang/gleam:v1.9.1-erlang-alpine

RUN gleam build
# Add project code
COPY . /build/

# Compile the project and copy assets
RUN cd /build \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && mkdir -p /app/src \
  && mkdir -p /app/public \
  && cp -r src/* /app/src/ \
  && cp -r public/* /app/public/ \
  && cp -r .env /app/ \
  && rm -r /build

# Run the server
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
