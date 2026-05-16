FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    git \
    build-essential \
    cmake \
    curl \
    wget

WORKDIR /app

# تحميل llama.cpp
RUN git clone https://github.com/ggml-org/llama.cpp.git .

# build
RUN make -j2

# مجلد النماذج
RUN mkdir -p models

# ===== اختر نموذج واحد فقط =====

# TinyLlama Q2
RUN wget -O models/model.gguf \
https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf

# ===== نهاية اختيار النموذج =====

EXPOSE 8000

CMD ["./server", \
"-m", "models/model.gguf", \
"--host", "0.0.0.0", \
"--port", "8000", \
"-c", "128", \
"-ngl", "0"]
