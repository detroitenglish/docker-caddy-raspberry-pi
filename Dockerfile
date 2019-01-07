FROM arm32v6/golang:1.11.4-alpine3.7

LABEL mantainer="Dave Willenberg <dave@detroit-english.de>" \
    org.label-schema.name="docker-caddy-rpi" \
    org.label-schema.description="Caddy Web Server on Docker for Raspberry Pi (arm7)" \
    org.label-schema.url="https://github.com/detroitenglish/docker-caddy-rpi" \
    org.label-schema.schema-version="1.0"

RUN apk add --update --no-cache git && go get github.com/mholt/caddy

# Edit this list below, defining your plugins with a space-seperated list
ENV CADDYPLUGINS='github.com/echocat/caddy-filter github.com/captncraig/caddy-realip github.com/caddyserver/dnsproviders/cloudflare'

RUN RUNFILE=$GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go \
  && for i in ${CADDYPLUGINS}; do sed -i "/\(imported\)/a_ \"${i}\"" $RUNFILE; done \
  && sed -i 's@EnableTelemetry = true@EnableTelemetry = false@' $RUNFILE

WORKDIR $GOPATH/src/github.com/mholt/caddy/caddy

RUN go get github.com/caddyserver/builds $CADDYPLUGINS \
  && go run build.go \
  && mv $PWD/caddy /usr/bin/ \
  && apk del git \
  && rm -fr $GOPATH/src/github.com/*

COPY Caddyfile /etc/Caddyfile

COPY index.html /srv/index.html

EXPOSE 80 443 2015

VOLUME /root/.caddy

WORKDIR /srv

ENTRYPOINT ["/usr/bin/caddy"]

CMD ["-agree", "-conf", "/etc/Caddyfile", "-log", "stdout", "-root", "/tmp"]
