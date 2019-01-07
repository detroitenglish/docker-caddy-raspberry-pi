FROM arm32v6/golang:1.11.4-alpine3.7

RUN apk add --update --no-cache git && go get github.com/mholt/caddy github.com/caddyserver/builds

# Edit this list below, defining your plugins with a space-seperated list
ENV CADDYPLUGINS='github.com/echocat/caddy-filter github.com/captncraig/caddy-realip github.com/caddyserver/dnsproviders/cloudflare'

RUN go get $CADDYPLUGINS && RUNFILE=$GOPATH/src/github.com/mholt/caddy/caddy/caddymain/run.go \
  && for i in ${CADDYPLUGINS}; do sed -i "/\(imported\)/a_ \"${i}\"" $RUNFILE; done \
  && sed -i 's@EnableTelemetry = true@EnableTelemetry = false@' $RUNFILE \
  && cd $GOPATH/src/github.com/mholt/caddy/caddy && go run build.go \
  && mv $GOPATH/src/github.com/mholt/caddy/caddy/caddy /usr/bin/local/caddy \
  && apk del git

COPY Caddyfile /etc/Caddyfile

COPY index.html /srv/index.html

EXPOSE 80 443 2015

VOLUME /root/.caddy

WORKDIR /srv

ENTRYPOINT ["/usr/bin/local/caddy"]

CMD ["--agree", "--conf", "/etc/Caddyfile", "--log", "stdout", "--root", "/tmp"]
