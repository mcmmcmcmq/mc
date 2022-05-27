
FROM alpine:latest as tailscale
WORKDIR /app
ENV TSFILE=tailscale_1.18.2_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1

FROM ubuntu:latest
# Copy binary to production image
COPY --from=tailscale /app/tailscaled /app/tailscaled
COPY --from=tailscale /app/tailscale /app/tailscale


ADD configure.sh /configure.sh
RUN apt update -y \
	&& apt upgrade -y \
 	&& apt install -y vim screen wget curl openjdk-8-jre-headless unzip git\
	&& chmod +x /configure.sh 
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV LANG C.UTF-8
CMD /start.sh
