class Adaptivecpp < Formula
  desc "SYCL and C++ standard parallelism for CPUs and GPUs"
  homepage "https://github.com/AdaptiveCpp/AdaptiveCpp"
  url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/v24.10.0.tar.gz"
  sha256 "3bcd94eee41adea3ccc58390498ec9fd30e1548af5330a319be8ce3e034a6a0b"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "libomp"
  depends_on "llvm"

  def install
    # Determine the compiler path based on the platform
    if OS.mac?
      # For macOS, use xcrun to find the system clang++
      clang_path = `xcrun -f clang++`.chomp
      cc_path = `xcrun -f clang`.chomp
    else
      # For Linux, use 'which' or 'command -v' to find clang++ or g++
      # Get the LLVM installation path
      llvm_prefix = Formula["llvm"].opt_prefix

      # Ensure that the correct clang++ is used from the LLVM dependency
      clang_path = "#{llvm_prefix}/bin/clang++"
      cc_path = "#{llvm_prefix}/bin/clang"
    end

    # Explicitly set CXX and CC to the system compiler paths
    ENV["CXX"] = clang_path
    ENV["CC"] = cc_path

    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    # Add a test to verify the software works (optional)
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
