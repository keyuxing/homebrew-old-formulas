class OpenconnectAT820 < Formula
  desc "Open client for Cisco AnyConnect VPN"
  homepage "https://www.infradead.org/openconnect/"
  url "ftp://ftp.infradead.org/pub/openconnect/openconnect-8.20.tar.gz"
  mirror "https://fossies.org/linux/privat/openconnect-8.20.tar.gz"
  sha256 "c1452384c6f796baee45d4e919ae1bfc281d6c88862e1f646a2cc513fc44e58b"
  license "LGPL-2.1-only"

  livecheck do
    url "https://www.infradead.org/openconnect/download.html"
    regex(/href=.*?openconnect[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  head do
    url "git://git.infradead.org/users/dwmw2/openconnect.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gnutls"
  depends_on "stoken"
  depends_on "libiconv"

  resource "vpnc-script" do
    url "https://gitlab.com/openconnect/vpnc-scripts/raw/cda38498bee5e21cb786f2c9e78ecab251c997c3/vpnc-script"
    sha256 "f17be5483ee048973af5869ced7b080f824aff013bb6e7a02e293d5cd9dff3b8"
  end

  def install
    etc.install resource("vpnc-script")
    chmod 0755, "#{etc}/vpnc-script"

    if build.head?
      ENV["LIBTOOLIZE"] = "glibtoolize"
      system "./autogen.sh"
    end

    args = %W[
      --prefix=#{prefix}
      --sbindir=#{bin}
      --localstatedir=#{var}
      --with-vpnc-script=#{etc}/vpnc-script
      LDFLAGS=-L#{Formula["libiconv"].opt_lib}
      CPPFLAGS=-I#{Formula["libiconv"].opt_include}
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "POST https://localhost/", pipe_output("#{bin}/openconnect localhost 2>&1")
  end
end
