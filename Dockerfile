# To build image:
#   docker build -t muen-website .
# To run image:
#   docker run -it --rm --net=host -p 4242:4242 muen-website
#
# Thanks to the asciidoctor team for this great work!
#

FROM fedora:24

LABEL maintainer="reet@codelabs.ch"
LABEL description="This image provides the toolchain for building the muen.sk website."

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
ENV SITE_REPO https://github.com/codelabs-ch/website-muen.sk
ENV MUEN_REPO https://github.com/codelabs-ch/muen.git
ENV PROJECT_DIR $HOME/website-muen.sk

ENV LANG en_US.UTF-8

WORKDIR $HOME

ARG site_branch=master
ADD https://api.github.com/repos/codelabs-ch/website-muen.sk/compare/$site_branch...HEAD /dev/null
RUN git clone --single-branch --depth 1 -b $site_branch $SITE_REPO $PROJECT_DIR
WORKDIR $PROJECT_DIR

RUN bundle config --local build.nokogiri --use-system-libraries
RUN bundle --path=.bundle/gems
RUN rm -rf .bundle/gems/ruby/*/cache

ARG muen_branch=master
ADD https://api.github.com/repos/codelabs-ch/muen/compare/$muen_branch...HEAD /dev/null
RUN git clone -b $muen_branch $MUEN_REPO ../muen
RUN tail -n +4 ../muen/README > README.adoc \
	&& mkdir articles \
	&& find ../muen/doc/articles -maxdepth 1 -type f -exec cp {} articles \; \
	&& find ../muen/doc/articles/images -maxdepth 1 -type f -exec cp {} images \;

EXPOSE 4242

CMD ["bash", "--login"]
