# =============================================
# STAGE 1: BUILD
# =============================================
# We use a "multi-stage build." This means we use one container to BUILD
# the app (which needs build tools), and a DIFFERENT container to RUN it.
# The final container won't have any build tools in it — fewer tools means
# fewer things an attacker can exploit.

FROM node:20-alpine AS builder
# "FROM" = start with this base image
# "node:20-alpine" = Node.js version 20 on Alpine Linux
#   Why Alpine? It's a tiny Linux (5MB vs 900MB for Ubuntu).
#   Fewer packages = smaller attack surface.
# "AS builder" = give this stage a name so we can reference it later

RUN apk add --no-cache git python3 make g++

WORKDIR /app
# Set the working directory inside the container to /app
# All following commands will run from here

COPY juice-shop/ .
# Copy full source first — Juice Shop's postinstall script needs the
# frontend/ directory present before npm install can succeed.

RUN npm install --omit=dev
# "--omit=dev" skips dev dependencies we don't need in the final container
# (test frameworks, linters, etc.)
# NOW copy the rest of the application code


# =============================================
# STAGE 2: PRODUCTION (this is the actual final container)
# =============================================
FROM node:20-alpine
# Start fresh with a clean Alpine image
# The build tools from Stage 1 are NOT carried over — this is the point
# of multi-stage builds

# SECURITY: Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
# By default, containers run as "root" (the superuser who can do anything).
# If an attacker breaks into your app, they'd have root access to the container.
# Creating a limited user means even if they break in, they can't do much.
# "-S" = system user/group (no home directory, no login shell)

WORKDIR /app

COPY --from=builder /app .
# Copy the built application FROM the "builder" stage
# This is the magic of multi-stage builds — we only take the finished product

# Give appuser ownership of directories the app writes to at runtime
RUN mkdir -p data/chatbot && chown -R appuser:appgroup /app

# SECURITY: Switch to the non-root user
USER appuser
# From this point, everything runs as "appuser" not "root"
# This is the Principle of Least Privilege — give only the minimum access needed

EXPOSE 3000
# Tell Docker this container will use port 3000
# This doesn't actually open the port — it's documentation for humans
# The actual port opening happens with "-p 3000:3000" when you run the container

# SECURITY: Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1
# Every 30 seconds, check if the app is still responding
# If it's not, Docker marks the container as "unhealthy"
# This helps monitoring systems detect and restart failed containers

CMD ["npm", "start"]
# The command that runs when the container starts
