class Adaptivecpp < Formula
    desc "AdaptiveCpp - Implementation of SYCL and C++ standard parallelism for CPUs and GPUs from all vendors"
    homepage "https://github.com/AdaptiveCpp/AdaptiveCpp"
    url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/v24.10.0.tar.gz" 
    sha256 "3bcd94eee41adea3ccc58390498ec9fd30e1548af5330a319be8ce3e034a6a0b"  # Replace with the actual checksum of the tarball
  
    depends_on "cmake" => :build
    depends_on "boost"
    depends_on "libomp"
  
    def install
      system "cmake", ".", *std_cmake_args
      system "make", "install"
    end
  
    test do
        # Add a test to verify the software works (optional)
        system "#{bin}/acpp", "--version"

        (testpath/"hellosycl.cpp").write <<~'C'
            #include <sycl/sycl.hpp>

            int main(){
            }
            C
        system bin/"acpp", "hellosycl.cpp", "-o", "hello"
        system "./hello"
    end
  end
