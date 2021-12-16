FROM ubuntu:latest
ADD Manager /opt/MCSManager/
ADD configure.sh /configure.sh
RUN apt update -y \
	&& apt upgrade -y \
 	&& apt install -y vim screen wget curl \
	&& chmod +x /configure.sh
ENV LANG C.UTF-8
CMD /configure.sh
