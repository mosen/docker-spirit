# Spirit 1.6.12 Dockerfile
FROM phusion/passenger-ruby21:0.9.15
MAINTAINER Mosen <mosen@github.com>

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV TIME_ZONE utc
# Although RACK_ENV is ignored by passenger, it is required for the build steps
ENV RACK_ENV production

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Necessary to compile gems
RUN apt-get update && apt-get install -y \
  sqlite3 \
  libsqlite3-dev \
  libavahi-compat-libdnssd-dev

# Image seems to ship with outdated bundler, which generates SSL CA errors for me.
RUN gem update bundler

WORKDIR /home/app
RUN git clone https://github.com/mosen/spirit.git spirit

WORKDIR /home/app/spirit
#USER app
RUN bundle install --without test
RUN bundle exec rake spirit:repo
RUN bundle exec rake ar:migrate
#USER root
RUN mkdir -p /etc/my_init.d
ADD nginx/nginx-env.conf /etc/nginx/main.d/
ADD nginx/spirit.conf /etc/nginx/sites-enabled/spirit.conf
ADD .docker/run.sh /etc/my_init.d/run.sh
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
RUN chown -R app:app /home/app

# EXPOSE 80
EXPOSE 60080

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
