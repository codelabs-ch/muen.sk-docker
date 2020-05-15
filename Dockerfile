# To build image:
#   docker build -t muen.sk-docker .
# To run image:
#   docker run -it --rm --net=host -p 4242:4242 muen.sk-docker
#
# Thanks to the asciidoctor team for this great work!
#

FROM fedora:24

LABEL maintainer="reet@codelabs.ch"
LABEL description="This image provides the toolchain for building the muen.sk website."

ENV HOME /home/writer
ENV PROJECT_DIR $HOME/website-muen.sk
ENV LANG en_US.UTF-8

RUN echo "deltarpm=false" >> /etc/dnf/dnf.conf

RUN dnf -y update
RUN dnf -y install \
  git \
  libffi-devel \
  libxml2-devel \
  libxslt-devel \
  patch redhat-rpm-config \
  ruby-devel \
  wget \
  rubygem-bundler
RUN dnf -y groupinstall "C Development Tools and Libraries"
RUN dnf clean all

RUN echo -e "To launch site, use the following command:\n\n $ bundle exec rake preview" > /etc/motd
RUN echo "[ -v PS1 -a -r /etc/motd ] && cat /etc/motd" > /etc/profile.d/motd.sh

RUN groupadd -r writer && useradd  -g writer -u 1000 writer
RUN mkdir -p $HOME && chmod 755 $HOME
ADD . $PROJECT_DIR
RUN chown -R writer:writer $HOME

USER writer
WORKDIR $PROJECT_DIR

RUN bundle config --local build.nokogiri --use-system-libraries --with-xml2-include=/usr/include/libxml2
RUN bundle --path=.bundle/gems
RUN rm -rf .bundle/gems/ruby/*/cache

EXPOSE 4242

CMD ["bash", "--login"]
