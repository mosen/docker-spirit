# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-full:0.9.11
MAINTAINER Victor Vrantchan <vrancean@gmail.com>

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV APP_DIR /home/app/spirit
ENV TIME_ZONE America/New_York

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]
RUN apt-get update && apt-get install -y \
  sqlite3 \
  libsqlite3-dev

RUN git clone https://github.com/mosen/spirit.git $APP_DIR
#RUN echo "Defaults    visiblepw" >> /etc/sudoers
WORKDIR /home/app/spirit
#USER app
RUN bundle install
RUN bundle exec rake spirit:repo
RUN bundle exec rake ar:migrate
USER root
RUN mkdir -p /etc/my_init.d
ADD nginx/nginx-env.conf /etc/nginx/main.d/
ADD nginx/spirit.conf /etc/nginx/sites-enabled/spirit.conf
ADD .docker/run.sh /etc/my_init.d/run.sh
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
RUN chown -R app:app /home/app

EXPOSE 80
EXPOSE 60080

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
