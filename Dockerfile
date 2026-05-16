FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    git \
    cmake \
    build-essential \
    curl \
    wget \
    python3

WORKDIR /app

# تحميل llama.cpp
RUN git clone https://github.com/ggml-org/llama.cpp.git .
RUN mkdir build
WORKDIR /app/build

# build بـ CMake (بديل make)
RUN cmake .. -DCMAKE_BUILD_TYPE=Release
RUN cmake --build . -j2

WORKDIR /app

RUN mkdir -p models

# نموذج خفيف (TinyLlama Q2)
RUN wget -O models/model.gguf \
https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf

EXPOSE 8000

CMD ["./build/bin/llama-server", \
"-m", "models/model.gguf", \
"--host", "0.0.0.0", \
"--port", "8000", \
"-c", "128"]
