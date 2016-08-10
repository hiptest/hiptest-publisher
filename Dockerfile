FROM ruby:2.3-alpine
WORKDIR /app
VOLUME /app
COPY . $WORKDIR
RUN apk --no-cache add curl wget 
RUN apk --no-cache add build-base 
RUN apk --no-cache add git
RUN bundle install 
RUN chmod 777 .
RUN rake install
# Clean APK cache
RUN apk del curl wget build-base git
RUN rm -rf /var/cache/apk/*
ENTRYPOINT ["hiptest-publisher"]
