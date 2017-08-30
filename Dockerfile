#
# GitLab CI Android Runner
#
#
FROM openjdk:8-jdk

ENV ANDROID_BUILD_TOOLS "26.0.1"
ENV ANDROID_SDK_TOOLS "25.2.5"
ENV ANDROID_HOME "/android-sdk"
ENV PATH=$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Prepare dependencies
RUN mkdir $ANDROID_HOME \
  && apt-get update --yes \
  && apt-get install --yes wget tar unzip lib32stdc++6 lib32z1 libqt5widgets5 \
  && apt-get clean \
  && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install sdk tools
RUN wget -O android-sdk.zip https://dl.google.com/android/repository/tools_r${ANDROID_SDK_TOOLS}-linux.zip \
  && unzip -q android-sdk.zip -d $ANDROID_HOME \
  && rm android-sdk.zip

# Workaround for 
# Warning: File /root/.android/repositories.cfg could not be loaded.
RUN mkdir /root/.android \
  && touch /root/.android/repositories.cfg

# Workaround for host bitness error with android emulator
# https://stackoverflow.com/a/37604675/455578
RUN mv /bin/sh /bin/sh.backup /
  && cp /bin/bash /bin/sh

# Add tools from travis
ADD https://raw.githubusercontent.com/travis-ci/travis-cookbooks/ca800a93071a603745a724531c425a41493e70ff/community-cookbooks/android-sdk/files/default/android-wait-for-emulator /usr/local/bin/android-wait-for-emulator
RUN chmod +x /usr/local/bin/android-wait-for-emulator

# Add own tools
#COPY update_sdk /usr/local/bin/update_sdk
#RUN chmod +x /usr/local/bin/update_sdk 
COPY assure_emulator_awake.sh /usr/local/bin/assure_emulator_awake.sh
RUN chmod +x /usr/local/bin/assure_emulator_awake.sh


# Update platform and build tools
RUN echo "y" | sdkmanager "tools" "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS}"
#RUN update_sdk platform-tools \
#  && update_sdk build-tools-${ANDROID_BUILD_TOOLS}

# Update SDKs
RUN echo "y" | sdkmanager "platforms;android-26" "platforms;android-25"
#RUN update_sdk android-26 \
#  && update_sdk android-25

# Update emulators
RUN echo "y" | sdkmanager "system-images;android-25;google_apis;x86_64"
#RUN update_sdk sys-img-armeabi-v7a-google_apis-26 \
#  && update_sdk sys-img-armeabi-v7a-google_apis-25

# Update extra
RUN echo "y" | sdkmanager "extras;android;m2repository" "extras;google;m2repository" "extras;google;google_play_services"
#RUN update_sdk extra-android-m2repository \
#  && update_sdk extra-google-m2repository \
#  && update_sdk extra-google-google_play_services

# Constraint Layout
RUN echo "y" | sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN echo "y" | sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"
