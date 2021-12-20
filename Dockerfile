FROM ubuntu:latest
ADD Manager /opt/Manager/
ADD configure.sh /configure.sh
RUN apt update -y \
	&& apt upgrade -y \
 	&& apt install -y vim screen wget curl openjdk-8-jre-headless make python build-essential\
	&& chmod +x /configure.sh 
ARG PACKAGE_BASEURL=https://download.zerotier.com/debian/buster/pool/main/z/zerotier-one/
ARG ARCH=amd64
ARG VERSION=1.8.4
RUN curl -sSL -o zerotier-one.deb "${PACKAGE_BASEURL}/zerotier-one_${VERSION}_${ARCH}.deb"
COPY --from=stage zerotier-one.deb .

RUN dpkg -i zerotier-one.deb && rm -f zerotier-one.deb
RUN echo "${VERSION}" >/etc/zerotier-version
RUN rm -rf /var/lib/zerotier-one
COPY start.sh /start.sh
RUN chmod 755 /start.sh

ENV LANG C.UTF-8
CMD /start.sh
