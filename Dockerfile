# To build image:
#   docker build -t muen.sk-docker .
# To run image:
#   docker run -it --rm --net=host muen.sk-docker
#
# Thanks to the asciidoctor team for this great work!
#

FROM fedora:43

LABEL maintainer="reet@codelabs.ch"
LABEL description="This image provides the toolchain for building the muen.sk website."

ENV HOME=/home/writer
ENV PROJECT_DIR=$HOME/website-muen.sk
ENV LANG=en_US.UTF-8
ENV CFLAGS="-O2 -D_FORTIFY_SOURCE=2"

RUN echo "deltarpm=false" >> /etc/dnf/dnf.conf

RUN dnf -y update
RUN dnf -y install \
  git \
  libffi-devel \
  libxml2-devel \
  libxslt-devel \
  libyaml-devel \
  patch redhat-rpm-config \
  ruby-devel \
  wget \
  rubygem-bundler
RUN dnf -y install @c-development
RUN dnf clean all

RUN echo -e "To launch site, use the following command:\n\n $ bundle exec rake preview" > /etc/motd
RUN echo "[ -v PS1 -a -r /etc/motd ] && cat /etc/motd" > /etc/profile.d/motd.sh

RUN groupadd -r writer && useradd  -g writer -u 1000 writer
RUN mkdir -p $HOME && chmod 755 $HOME
COPY . $PROJECT_DIR
RUN chown -R writer:writer $HOME

USER writer
WORKDIR $PROJECT_DIR

RUN bundle config --local build.nokogiri --use-system-libraries --with-xml2-include=/usr/include/libxml2
RUN bundle config --local set path .bundle/gems
RUN bundle
RUN rm -rf .bundle/gems/ruby/*/cache

EXPOSE 4242

CMD ["bash", "--login"]
