# ONLY FOR RELEASE, NOT FOR CI/CD. WE CANNOT RUN TESTS FOR THIS BUILD

# Base
FROM node:12.20.0-alpine3.12 AS base
LABEL Name="cart-api"
LABEL Version="1.0"
WORKDIR /app


# Build Dependencies
FROM base AS build_dependencies
COPY package*.json ./
RUN npm install
# We cannot install only prod dependancies for the project. Otherwise the build will not be successful
# There is no need to clear npm cache for this stage


# Release Dependencies
FROM base AS release_dependencies
COPY package*.json ./
RUN npm install --only=prod
# There is no need to clear npm cache for this stage


# Build
FROM build_dependencies AS build
COPY tsconfig*.json ./
COPY src src
RUN npm run build


# Release
FROM base AS release
COPY --from=build /app/dist ./dist
COPY --from=release_dependencies /app/node_modules ./node_modules
USER node
ENV PORT=8080
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "dist/main.js"]
