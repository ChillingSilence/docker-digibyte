FROM debian:stable-slim

ENV HOME /digibyte

ENV USER_ID 1000
ENV GROUP_ID 1000
ENV DGB_VERSION=6.17.2

RUN groupadd -g ${GROUP_ID} digibyte \
  && useradd -u ${USER_ID} -g digibyte -s /bin/bash -m -d /digibyte digibyte \
  && set -x \
  && apt-get update -y \
  && apt-get install -y curl gosu \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://github.com/digibyte/digibyte/releases/download/v${DGB_VERSION}/digibyte-${DGB_VERSION}-x86_64-linux-gnu.tar.gz | tar xz --strip=2 -C /usr/local/bin

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/dgb_oneshot

VOLUME ["/digibyte"]

EXPOSE 12024 14022

WORKDIR /digibyte

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["dgb_oneshot"]
