class Adaptivecpp < Formula
  desc "SYCL and C++ standard parallelism for CPUs and GPUs"
  homepage "https://adaptivecpp.github.io/"
  url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/v25.02.0.tar.gz"
  sha256 "8cc8a3be7bb38f88d7fd51597e0ec924b124d4233f64da62a31b9945b55612ca"
  license "BSD-2-Clause"
  head "https://github.com/AdaptiveCpp/AdaptiveCpp.git", branch: "develop"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "llvm"
  depends_on "ninja"
  uses_from_macos "python"

  on_macos do
    depends_on "libomp"
  end

  def install
    args = []
    args << "-DLLVM_DIR=#{Formula["llvm"].opt_lib}/cmake/llvm" if OS.linux?
    if OS.mac?
      libomp_root = Formula["libomp"].opt_prefix
      args << "-DOpenMP_ROOT=#{libomp_root}"
    end

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Avoid references to Homebrew shims directory
    inreplace prefix/"etc/AdaptiveCpp/acpp-core.json", Superenv.shims_path/ENV.cxx, ENV.cxx
    return unless OS.mac?

    # we add -I#{libomp_root}/include to default-omp-cxx-flags
    inreplace prefix/"etc/AdaptiveCpp/acpp-core.json",
              "\"default-omp-cxx-flags\" : \"",
              "\"default-omp-cxx-flags\" : \"-I#{libomp_root}/include "
  end

  test do
    system bin/"acpp", "--version"

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
