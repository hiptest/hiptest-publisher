FROM ruby:2.3-onbuild
RUN chmod 777 .
RUN rake install
WORKDIR /app
VOLUME /app
ENTRYPOINT ["hiptest-publisher"]
