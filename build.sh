TERMUX_PKG_NAME=p-gass
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_DESCRIPTION="Bahasa pemrograman P‑Gass — sederhana & berkuasa"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Maverick03‑star <nandazakaria48@yahoo.com>"
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
    install -Dm755 p "$TERMUX_PREFIX/bin/p"
}
