FROM alpine:edge
MAINTAINER Roy Xiang <developer@royxiang.me>

ENV LANG C.UTF-8

RUN apk add --update --no-cache ca-certificates

RUN set -ex \
        && apk add --no-cache --virtual .run-deps \
                ffmpeg \
                libmagic \
                python3 \
                py3-certifi \
                py3-numpy \
                py3-pillow \
                py3-requests \
        && ln -sf "$(python3 -c 'import requests; print(requests.__path__[0])')/cacert.pem" \
                  "$(python3 -c 'import certifi; print(certifi.__path__[0])')/cacert.pem"

RUN set -ex \
        && apk add --update --no-cache --virtual .fetch-deps \
                curl \
                tar \
        && curl -L -o EFB-latest.tar.gz \
                $(curl -s https://api.github.com/repos/blueset/ehForwarderBot/tags \
                    | grep tarball_url | head -n 1 | cut -d '"' -f 4) \
        && mkdir -p /opt/ehForwarderBot/storage \
	&& chmod +rw /opt/ehForwarderBot/storage \
        && tar -xzf EFB-latest.tar.gz --strip-components=1 -C /opt/ehForwarderBot \
        && rm EFB-latest.tar.gz \
        && apk del .fetch-deps \
        && pip3 install -r /opt/ehForwarderBot/requirements.txt \
        && rm -rf /root/.cache

RUN apk add curl
RUN curl -s https://raw.githubusercontent.com/blueset/ehForwarderBot/master/config.sample.py -o /mnt/config.py
VOLUME /mnt
RUN touch /mnt/tgdata.db
RUN ln -s /mnt/tgdata.db /opt/ehForwarderBot/plugins/eh_telegram_master/tgdata.db 
RUN ln -s /mnt/config.py /opt/ehForwarderBot/config.py
WORKDIR /opt/ehForwarderBot
CMD ["python3", "main.py"]
