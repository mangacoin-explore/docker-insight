FROM node:6.9.4

# for force automated-build
RUN echo 4

RUN apt-get update && apt-get upgrade -y && apt-get install -y libzmq3-dev
RUN npm install --unsafe-perm -g mangacore-node@3.1.3-pre-7
USER node
WORKDIR /home/node
RUN mangacore-node create insight
WORKDIR /home/node/insight
RUN mangacore-node install @mangacoin-explore/insight-api-mxxgacoin
RUN mangacore-node install @mangacoin-explore/insight-ui-mxxgacoin
COPY bitcore-node.json .

VOLUME /home/node/insight/data
CMD /home/node/insight/node_modules/mangacore-node/bin/mangacore-node start

EXPOSE 3001 9401
