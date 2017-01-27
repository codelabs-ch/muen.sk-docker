# To build image:
# docker build -t muen/muen-site .
# To run image:
# docker run -it --rm --net=host -p 4242:4242 muen/muen-site
#
# Thanks to the asciidoctor team for this great work!
#

FROM fedora:24
MAINTAINER Asciidoctor

LABEL Description="This image provides the toolchain for building the muen.sk website."

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
RUN mkdir -p /home/writer
RUN chown writer:writer /home/writer

USER writer

ENV HOME /home/writer
ENV PROJECT_GIT_REPO https://github.com/codelabs-ch/website-muen.sk
ENV PROJECT_DIR $HOME/website-muen.sk
ENV README_URL=https://git.codelabs.ch/?p=muen.git;a=blob_plain;f=README

ENV LANG en_US.UTF-8

WORKDIR $HOME

RUN git clone --single-branch --depth 1 $PROJECT_GIT_REPO $PROJECT_DIR
WORKDIR $PROJECT_DIR
RUN wget $README_URL -O README.tmp
RUN tail -n +4 README.tmp > README.adoc
RUN rm README.tmp
RUN bundle config --local build.nokogiri --use-system-libraries
RUN bundle --path=.bundle/gems
RUN rm -rf .bundle/gems/ruby/*/cache

EXPOSE 4242

CMD ["bash", "--login"]
