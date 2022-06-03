FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev \
    libjpeg-dev 
RUN git clone https://github.com/serge1/ELFIO.git
WORKDIR /ELFIO
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ .
RUN make
RUN make install
COPY fuzzers/fuzz_read_elf.cpp .
RUN afl-clang++ -I/usr/local/lib fuzz_read_elf.cpp -o /fuzzELF
RUN mkdir /elfCorpus
#RUN cp /fuzzELF /elfCorpus
#RUN cp /usr/bin/ping /elfCorpus
RUN cp /usr/bin/whoami /elfCorpus
RUN wget https://github.com/JonathanSalwan/binary-samples/raw/master/elf-Linux-x86-bash
RUN mv elf-Linux-x86-bash /elfCorpus

ENTRYPOINT ["afl-fuzz", "-i", "/elfCorpus", "-o", "/elfioOut"]
CMD ["/fuzzELF", "@@"]
