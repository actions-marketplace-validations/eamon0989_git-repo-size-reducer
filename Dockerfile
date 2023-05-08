FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && \
    apt-get -y install git-filter-repo curl bc
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash && apt-get -y install nodejs
RUN git config --system --add safe.directory /github/workspace
COPY ./entrypoint.sh ./get-files-to-delete.mjs ./package.json ./package-lock.json ./
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
