# Stage and thin the application
FROM openliberty/open-liberty:21.0.0.1-full-java11-openj9-ubi as staging

COPY --chown=1001:0 target/product-0.0.1-SNAPSHOT.jar /staging/fat-product-0.0.1-SNAPSHOT.jar

RUN springBootUtility thin --sourceAppPath=/staging/fat-product-0.0.1-SNAPSHOT.jar --targetThinAppPath=/staging/thin-product-0.0.1-SNAPSHOT.jar --targetLibCachePath=/staging/lib.index.cache

# Build the image
FROM openliberty/open-liberty:21.0.0.1-kernel-slim-java11-openj9-ubi

ARG VERSION=1.0
ARG REVISION=SNAPSHOT

LABEL org.opencontainers.image.authors="UCLL"\
  org.opencontainers.image.vendor="UCLL OpenLiberty"\
  org.opencontainers.image.url="local"\
  org.opencontainers.image.source="https://github.com/OpenLiberty/guide-spring-boot"\
  org.opencontainers.image.version="$VERSION"\
  org.opencontainers.image.revision="$REVISION"\
  vendor="UCLL Open Liberty"\
  name="product"\
  version="$VERSION-$REVISION"\
  summary="The product application from the Spring Boot tutorial"\
  description="This image contains the product application running with the Open Liberty runtime."

COPY --chown=1001:0 src/main/liberty/config /config/

# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility.
# Only available in 'kernel-slim'. The 'full' tag already includes all features for convenience.
RUN features.sh

COPY --chown=1001:0 --from=staging /staging/lib.index.cache /lib.index.cache
COPY --chown=1001:0 --from=staging /staging/thin-product-0.0.1-SNAPSHOT.jar /config/apps/thin-product-0.0.1-SNAPSHOT.jar

RUN configure.sh