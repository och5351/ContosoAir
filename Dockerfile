FROM node:6.2.2
VOLUME /tmp

RUN mkdir -p /app
WORKDIR /app
ADD . /app
RUN npm install

ENV NODE_ENV development