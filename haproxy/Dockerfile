# HAProxy custom image
FROM haproxy:2.8-alpine

# Copy configuration file
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# Expose port 80 for web traffic and 8404 for stats
EXPOSE 80 8404