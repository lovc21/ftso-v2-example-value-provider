FROM node:25-slim@sha256:e07427bc8f075386eafa62c1ddab758815f1fd11dd8eaacb61919e8b09ab00b3 AS nodemodules

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 100000

FROM node:25-slim@sha256:e07427bc8f075386eafa62c1ddab758815f1fd11dd8eaacb61919e8b09ab00b3 AS build

WORKDIR /app

COPY --from=nodemodules /app/node_modules /app/node_modules
COPY . ./

RUN yarn build

FROM platformatic/node-caged:25-slim@sha256:2e86809930b76cce928de00d3ef107be51adaa913d963c5c82553257db2d93e5 AS runtime

WORKDIR /app

COPY --from=nodemodules /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
COPY src/config src/config

CMD ["node", "dist/main.js"]
