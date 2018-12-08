FROM nao20010128nao/homebrew-bitzeny-hacked:mangacoin-addrindex as mangabin

FROM node:6.9.4

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y libzmq3-dev nano patch tar wget
RUN npm install --unsafe-perm -g https://github.com/neginegi0/mangacore-node
WORKDIR /usr/local/lib/node_modules/mangacore-node
COPY --from=mangabin /usr/bin/mangacoind /usr/bin/mangacoind

COPY --from=mangabin /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so.7
COPY --from=mangabin /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libm.so.7
RUN rm /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /lib/x86_64-linux-gnu/libm.so.6 && \
    ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.7 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
    ln -s /lib/x86_64-linux-gnu/libm.so.7 /lib/x86_64-linux-gnu/libm.so.6 && \
    /usr/bin/mangacoind -version

USER node
WORKDIR /home/node
RUN mangacore-node create insight
WORKDIR /home/node/insight
RUN mangacore-node install https://github.com/neginegi0/insight-manga-api/archive/master.tar.gz https://github.com/neginegi0/insight-manga-ui/archive/master.tar.gz
COPY mangacore-node.json .
COPY no-bitcore-check.diff /tmp
RUN mkdir /home/node/insight/datadir && chown node:node /home/node/insight/datadir
WORKDIR /home/node/insight/node_modules/mangacore-node
RUN cat /tmp/no-bitcore-check.diff | patch -p1
COPY --chown=node:node mangacoind-wrapper bin/mangacoind
RUN chmod a=rx bin/mangacoind
WORKDIR /home/node/insight

VOLUME /home/node/insight/datadir
CMD /home/node/insight/node_modules/mangacore-node/bin/mangacore-node start

EXPOSE 8080
