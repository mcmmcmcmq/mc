FROM golang:1.16.2-alpine3.13 as builder
WORKDIR /app
COPY . ./
RUN go build -o app ./main.go

FROM alpine:latest as tailscale
WORKDIR /app
ENV TSFILE=tailscale_1.14.0_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1

FROM ubuntu:latest
# Copy binary to production image
COPY --from=builder /app/app /app/app
COPY --from=tailscale /app/tailscaled /app/tailscaled
COPY --from=tailscale /app/tailscale /app/tailscale


ADD Manager /opt/Manager/
ADD configure.sh /configure.sh
RUN apt update -y \
	&& apt upgrade -y \
 	&& apt install -y vim screen wget curl openjdk-8-jre-headless make python build-essential unzip git\
	&& chmod +x /configure.sh 
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV LANG C.UTF-8
CMD /start.sh
