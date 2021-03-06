require 'formula'

class Gtkx3 < Formula
  homepage 'http://gtk.org/'
  url "http://ftp.gnome.org/pub/gnome/sources/gtk+/3.14/gtk+-3.14.6.tar.xz"
  sha256 "cfc424e6e10ffeb34a33762aeb77905c3ed938f0b4006ddb7e880aad234ef119"
  revision 1

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha1 "af96d59d04494cbe4fdb3ce5fb15e6cf974fb485" => :yosemite
    sha1 "47189a853fbeac6eb686efb9d060cce0020c49f4" => :mavericks
    sha1 "6c542f5d3b84314c6a607daccd4279e43e559182" => :mountain_lion
  end

  depends_on 'staticfloat/juliadeps/pkg-config' => :build
  depends_on 'xz' => :build
  depends_on 'staticfloat/juliadeps/glib'
  depends_on 'staticfloat/juliadeps/gobject-introspection'
  depends_on 'jpeg'
  depends_on 'libtiff'
  depends_on 'staticfloat/juliadeps/gdk-pixbuf'
  depends_on 'staticfloat/juliadeps/pango'
  depends_on 'staticfloat/juliadeps/cairo'
  depends_on 'staticfloat/juliadeps/atk'

  def install
    ENV.universal_binary if build.universal?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-glibtest
      --enable-introspection=yes
      --disable-schemas-compile
      --enable-quartz-backend
      --enable-quartz-relocation
      --disable-x11-backend
    ]

    system "./configure", *args
    system "make", "install"
    # Prevent a conflict between this and Gtk+2
    mv bin/"gtk-update-icon-cache", bin/"gtk3-update-icon-cache"
  end

  # Note that you need to define XDG_DATA_DIRS="#{HOMEBREW_PREFIX}/share" to use the schemas properly
  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
  end
end
