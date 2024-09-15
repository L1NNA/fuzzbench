FROM ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update; \
    apt-get install -y python3 python3-pip python3-venv;

RUN mkdir /workspace && cd /workspace && cat <<EOF > requirements.txt
ollama
redis
EOF

COPY llm.py /workspace
WORKDIR /workspace

RUN python3 -m venv .llm-venv && .llm-venv/bin/pip install -r requirements.txt

ENTRYPOINT [ ".llm-venv/bin/python" ]

CMD [ "llm.py" ]


