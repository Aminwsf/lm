FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    git \
    build-essential \
    cmake \
    curl \
    wget \
    python3

WORKDIR /app

# ---- clone llama.cpp ----
RUN git clone https://github.com/ggml-org/llama.cpp .
 
# ---- build with CMake ----
RUN mkdir build && cd build && cmake .. && cmake --build . -j2

# ---- model ----
RUN mkdir -p models

RUN wget -O models/model.gguf \
https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf

EXPOSE 8000

# ---- OpenAI compatible server ----
CMD ["./build/bin/llama-server", \
"-m", "models/model.gguf", \
"--host", "0.0.0.0", \
"--port", "8000", \
"-c", "128", \
"--chat-template", "chatml"]
