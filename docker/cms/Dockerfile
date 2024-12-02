# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install python/make/g++ for node-gyp
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source files
COPY . .

# Build Strapi admin
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV=production

# Install production dependencies
COPY package*.json ./
RUN npm ci --production

# Copy built files from builder
COPY --from=builder /app/build ./build
COPY --from=builder /app/config ./config
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Create required directories
RUN mkdir -p /app/public/uploads

# Expose port
EXPOSE 1337

# Start Strapi
CMD ["npm", "start"]
