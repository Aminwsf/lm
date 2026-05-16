FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    git \
    cmake \
    build-essential \
    curl \
    wget \
    python3 \
    && apt clean

WORKDIR /app

# ===== clone llama.cpp =====
RUN git clone https://github.com/ggml-org/llama.cpp.git .
RUN mkdir build

WORKDIR /app/build

# ===== build minimal =====
RUN cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=ON

RUN cmake --build . -j2

WORKDIR /app

RUN mkdir -p models

# ===== SMALL MODEL (IMPORTANT) =====
# Qwen 0.5B Q2 (أخف خيار عملي)
RUN wget -O models/model.gguf \
https://huggingface.co/Qwen/Qwen2-0.5B-Instruct-GGUF/resolve/main/qwen2-0_5b-instruct-q2_k.gguf

# ===== RUN CONFIG =====
EXPOSE 8000

CMD ["./build/bin/llama-server","-m","models/model.gguf","--host","0.0.0.0","--port","8000","-c","32","-t","1","--parallel","1","--mlock","0","--no-mmap"]
