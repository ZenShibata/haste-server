FROM ghcr.io/hazmi35/node:16-dev-alpine as build-stage

LABEL name "haste-server (build-stage)"

WORKDIR /tmp/build

# Now copy project files
COPY . .

# Install node dependencies
RUN npm ci --production

# Get ready for production
FROM ghcr.io/hazmi35/node:16-alpine

LABEL name "haste-server"

WORKDIR /app

# Copy files from build-stage
COPY --from=build-stage /tmp/build/package*.json .
COPY --from=build-stage /tmp/build/*.js .
COPY --from=build-stage /tmp/build/lib ./lib
COPY --from=build-stage /tmp/build/docker-entrypoint.* .
COPY --from=build-stage /tmp/build/static ./static
COPY --from=build-stage /tmp/build/node_modules ./node_modules
COPY --from=build-stage /tmp/build/*.md .

ENV STORAGE_TYPE=memcached \
    STORAGE_HOST=127.0.0.1 \
    STORAGE_PORT=11211\
    STORAGE_EXPIRE_SECONDS=2592000\
    STORAGE_DB=2 \
    STORAGE_AWS_BUCKET= \
    STORAGE_AWS_REGION= \
    STORAGE_USENAME= \
    STORAGE_PASSWORD= \
    STORAGE_FILEPATH=

ENV LOGGING_LEVEL=verbose \
    LOGGING_TYPE=Console \
    LOGGING_COLORIZE=true

ENV HOST=0.0.0.0\
    PORT=7777\
    KEY_LENGTH=10\
    MAX_LENGTH=400000\
    STATIC_MAX_AGE=86400\
    RECOMPRESS_STATIC_ASSETS=true

ENV KEYGENERATOR_TYPE=phonetic \
    KEYGENERATOR_KEYSPACE=

ENV RATELIMITS_NORMAL_TOTAL_REQUESTS=500\
    RATELIMITS_NORMAL_EVERY_MILLISECONDS=60000 \
    RATELIMITS_WHITELIST_TOTAL_REQUESTS= \
    RATELIMITS_WHITELIST_EVERY_MILLISECONDS=  \
    # comma separated list for the whitelisted \
    RATELIMITS_WHITELIST=example1.whitelist,example2.whitelist \
    \
    RATELIMITS_BLACKLIST_TOTAL_REQUESTS= \
    RATELIMITS_BLACKLIST_EVERY_MILLISECONDS= \
    # comma separated list for the blacklisted \
    RATELIMITS_BLACKLIST=example1.blacklist,example2.blacklist
ENV DOCUMENTS=about=./about.md

EXPOSE ${PORT}/tcp
STOPSIGNAL SIGINT
ENTRYPOINT [ "ash", "docker-entrypoint.sh" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s \
    --retries=3 CMD node healthcheck.js
CMD ["node", "server.js"]
