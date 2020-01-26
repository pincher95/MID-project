FROM alpine:latest
LABEL maintainer="pincher95" name="foaas"
WORKDIR /src
EXPOSE 5000
ENTRYPOINT [ "npm" ]
CMD [ "start" ]
RUN apk update && apk add nodejs npm
COPY foaas/ /src
RUN npm install