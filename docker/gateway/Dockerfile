FROM openclaw:local

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3-pip \
 && rm -rf /var/lib/apt/lists/*

COPY wheels/*.whl /tmp/wheels/
RUN pip install --break-system-packages --no-cache-dir /tmp/wheels/*.whl \
 && rm -rf /tmp/wheels

ENV BORGPRIME_URL=http://host.docker.internal:5000

USER node
