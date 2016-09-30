#
# GitLab CI: Android v0.2
#
# https://hub.docker.com/r/showcheap/gitlab-ci-android/
#

FROM ubuntu:16.04
MAINTAINER Sucipto <chip@pringstudio.com>

ENV VERSION_SDK_TOOLS "25.2.2"
ENV VERSION_BUILD_TOOLS "24.0.3"
ENV VERSION_TARGET_SDK "23"

ENV SDK_PACKAGES "build-tools-${VERSION_BUILD_TOOLS},android-${VERSION_TARGET_SDK},addon-google_apis-google-${VERSION_TARGET_SDK},platform-tools,extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository,sys-img-armeabi-v7a-android-${VERSION_TARGET_SDK},sys-img-x86-android-${VERSION_TARGET_SDK}"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

# Accept License

# Constraint Layout / [Solver for ConstraintLayout 1.0.0-alpha8, ConstraintLayout for Android 1.0.0-alpha8]
RUN mkdir -p $ANDROID_HOME/licenses/
RUN echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license

RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      curl \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      qtbase5-dev \
      qtdeclarative5-dev \
      xorg-dev \
      libxaw7-dev \
      x11vnc \
      wget \
      xutils-dev \
      gcc \
      ffmpeg2theora \
      qemu-kvm \
      tightvncserver \
      xfonts-base \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN wget -nv http://dl.google.com/android/repository/tools_r${VERSION_SDK_TOOLS}-linux.zip && unzip tools_r${VERSION_SDK_TOOLS}-linux.zip -d /sdk && \
    rm -v tools_r${VERSION_SDK_TOOLS}-linux.zip

COPY wait-for-avd-boot.sh /sdk/platform-tools

RUN mkdir /sdk/tools/keymaps && \
    touch /sdk/tools/keymaps/en-us

RUN wget -nv http://ronja.twibright.com/utils/vncrec-twibright.tgz && tar -zxvf vncrec-twibright.tgz && rm vncrec-twibright.tgz && cd vncrec-twibright && \
    xmkmf && make World && \
    chmod a+x vncrec/vncrec && mv vncrec/vncrec /usr/local/bin && \
    chmod a+x vncconnect/vncconnect && mv vncconnect/vncconnect /usr/local/bin && \
    chmod a+x vncpasswd/vncpasswd && mv vncpasswd/vncpasswd /usr/local/bin

RUN (while [ 1 ]; do sleep 5; echo y; done) | ${ANDROID_HOME}/tools/android update sdk -u -a -t ${SDK_PACKAGES}
