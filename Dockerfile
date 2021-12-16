FROM ubuntu:latest
ADD Manager /opt/MCSManager/
RUN apt update -y \
	&& apt upgrade -y \
 	&& apt install -y vim screen wget curl
ENV LANG C.UTF-8
WORKDIR /home
CMD /configure.sh
