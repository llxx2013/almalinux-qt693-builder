FROM almalinux:8

ARG QT_BUILD_NPROC=8

ENV QT_VERSION=6.9.3
ENV QT_VERSION_MAJOR=6
ENV QT_DIR=/opt/Qt${QT_VERSION}
ENV BISON_VERSION=3.8.2
ENV ENABLE_GCC_TOOLSET=/opt/rh/gcc-toolset-14/enable
ENV BUILD_ARCH=x86_64
ENV APPIMAGE_EXTRACT_AND_RUN=1

RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y epel-release && \
	dnf install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm -y && \
    dnf makecache

RUN dnf install -y file cmake ninja-build git wget meson \
    gcc-toolset-14 gcc-toolset-14-gcc gcc-toolset-14-gcc-c++ gcc-toolset-14-libstdc++-devel \
    libxcb-devel libxkbcommon-devel libxkbcommon-x11-devel xcb-util-devel xcb-util-image-devel \
    libX11-devel libXext-devel mesa-libGL-devel mesa-libGLU-devel xcb-util-keysyms-devel \
    fontconfig-devel freetype-devel libpng-devel libjpeg-turbo-devel xcb-util-renderutil-devel libXcursor-devel libXfixes-devel \
    sqlite-devel libzstd-devel libicu-devel glib2-devel xcb-util-wm-devel libXrender-devel xcb-util-cursor-devel hunspell hunspell-*.noarch hunspell-devel \
	systemd-devel libb2-devel libproxy-devel at-spi2-core-devel mtdev-devel tslib-devel gtk3-devel libinput-devel \
	openssl3 openssl3-devel pcre2-devel harfbuzz-devel vulkan-headers mesa-libgbm-devel double-conversion-devel libwebp-devel libmng-devel glibc-langpack-en \
	protobuf-devel clang-devel wayland-devel wayland-protocols-devel libgbm-devel libdrm-devel mesa-libEGL-devel mesa-libGLES-devel libffi-devel \
    flex flex-devel m4 \
    && dnf clean all && rm -rf /var/cache/dnf/*
	
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /root

RUN . ${ENABLE_GCC_TOOLSET} && \
    WPROTO_VER=1.27 && \
    wget https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/${WPROTO_VER}/downloads/wayland-protocols-${WPROTO_VER}.tar.xz && \
    tar -xf wayland-protocols-${WPROTO_VER}.tar.xz && \
    cd wayland-protocols-${WPROTO_VER} && \
    meson setup build --prefix=/usr --buildtype=release && \
    ninja -C build install && \
    cd .. && \
    rm -rf wayland-protocols-${WPROTO_VER} wayland-protocols-${WPROTO_VER}.tar.xz

RUN wget https://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz \ 
    && tar -xzf bison-${BISON_VERSION}.tar.gz && rm -f bison-${BISON_VERSION}.tar.gz && cd bison-${BISON_VERSION} \
	&& . ${ENABLE_GCC_TOOLSET} && ./configure && make -j$(nproc) && make install && cd .. && rm -rf bison-${BISON_VERSION}
	
ARG QT_BIN_URL="https://github.com/llxx2013/almalinux-qt693-builder/releases/download/v6.9.3/qt-6.9.3-almalinux8-x86_64.tar.xz"

RUN mkdir -p /opt && \
    wget -qO- ${QT_BIN_URL} | tar -xJ -C /opt

RUN wget -qO /usr/local/bin/appimagetool https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-${BUILD_ARCH}.AppImage && \
    wget -qO /usr/local/bin/linuxdeploy https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${BUILD_ARCH}.AppImage && \
    wget -qO /usr/local/bin/linuxdeploy-plugin-qt https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-${BUILD_ARCH}.AppImage && \
    chmod +x /usr/local/bin/appimage* /usr/local/bin/linuxdeploy*

COPY qt-env.sh /etc/profile.d/

WORKDIR /root
ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["bash"]

