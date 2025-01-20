class Adaptivecpp < Formula
  desc "SYCL and C++ standard parallelism for CPUs and GPUs"
  homepage "https://github.com/AdaptiveCpp/AdaptiveCpp"
  url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/v24.10.0.tar.gz"
  sha256 "3bcd94eee41adea3ccc58390498ec9fd30e1548af5330a319be8ce3e034a6a0b"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "libomp"
  depends_on "llvm"
  depends_on "python"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"

    # Avoid references to Homebrew shims directory
    shim_references = [prefix/"etc/AdaptiveCpp/acpp-core.json"]
    inreplace shim_references, Superenv.shims_path/ENV.cxx, ENV.cxx
  end

  test do
    system "#{bin}/acpp", "--version"

    (testpath/"hellosycl.cpp").write <<~C
      #include <sycl/sycl.hpp>
      int main(){
          sycl::queue q{};
      }
    C
    system bin/"acpp", "hellosycl.cpp", "-o", "hello"
    system "./hello"
  end
end
