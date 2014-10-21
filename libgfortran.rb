require 'formula'
require 'find'

class Libgfortran < Formula
  homepage 'http://gcc.gnu.org/wiki/GFortran'
  url 'https://github.com/staticfloat/homebrew-libgfortran-formula/archive/master.tar.gz'
  sha1 '09328c065c42051fab341e660837704a3b1f5d4a'
  version '4.9.1'

  depends_on 'gcc' => :build

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 7
    sha1 'd2956ddd363264a91cb187153ea71d347f754b42' => :lion
    sha1 '72760be7529ec11fab7f45fcafb8a4ddbdcc3bb0' => :mavericks
    sha1 'e5259b55bd80cff543bbe580fedb15bb3538d0fd' => :mountain_lion
  end

  def install
    # To generate a libgfortran installation, steal libraries from gcc!
    mkdir_p lib
    Find.find("#{Formula['gcc'].lib}/gcc") do |path|
      for f in ['quadmath.0', 'gcc_s.1', 'gfortran.3']
        if /.*\/4.9.1\/lib#{f}.dylib/.match( path )
          system 'cp', path, lib
        end
      end
    end

    fixup_libgfortran(prefix)
  end
end

# Here, we're going to find all dylibs and install_name_tool them for libgfortran instead of gcc
def fixup_libgfortran(prefix)
  keg = Keg.for(prefix)
  libgfortran = Formula.factory("libgfortran")

  # For each dylib/executable within this keg
  keg.mach_o_files.each do |file|
    file.ensure_writable do
      # Search its dependent dylibs
      keg.each_install_name_for(file) do |bad_name|
        # If we find a quadmath, gcc, or gfortran,
        for f in ['quadmath.0', 'gcc_s.1', 'gfortran.3']
          if bad_name =~ /.*#{f}\.dylib/
            # Rename the dependency!
            good_name = libgfortran.opt_lib + Pathname.new(bad_name).basename
            keg.change_install_name(bad_name, good_name, file)
          end
        end
      end
    end
  end
end
