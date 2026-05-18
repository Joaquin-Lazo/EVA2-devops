#!/bin/sh
set -e

# Default upstreams match Docker Compose service names;
# override via env vars for AWS deployment.
export VENTAS_UPSTREAM="${VENTAS_UPSTREAM:-ventas-service:8080}"
export DESPACHOS_UPSTREAM="${DESPACHOS_UPSTREAM:-despachos-service:8081}"

# Generate nginx config from template (only substitute our vars, not nginx's $host etc.)
envsubst '${VENTAS_UPSTREAM} ${DESPACHOS_UPSTREAM}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Runtime environment variable injection for the SPA.
# Replaces placeholder values in the built JS with actual env vars.
# This allows a single Docker image to be used across environments.

echo "window.__ENV__ = {" > /usr/share/nginx/html/env-config.js
echo "  VITE_VENTAS_API_URL: \"${VITE_VENTAS_API_URL:-http://localhost:8080}\"," >> /usr/share/nginx/html/env-config.js
echo "  VITE_DESPACHOS_API_URL: \"${VITE_DESPACHOS_API_URL:-http://localhost:8081}\"" >> /usr/share/nginx/html/env-config.js
echo "};" >> /usr/share/nginx/html/env-config.js

exec "$@"
