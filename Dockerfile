ARG version="0.7.1"

# --------------------------------------------------------------------------------------------------------------
# ソースコードのダウンロードを行うステージ
# --------------------------------------------------------------------------------------------------------------

FROM ubuntu:22.04 AS downloader

ARG version

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends aria2 ca-certificates xz-utils

RUN mkdir -p /code

RUN cd /tmp && \
    aria2c -x10 https://github.com/tsukumijima/KonomiTV/archive/refs/tags/v${version}.tar.gz -o source.tar.gz && \
    tar xvf source.tar.gz --strip-components=1 -C /code

RUN cd /tmp && \
    aria2c -x10 https://github.com/tsukumijima/KonomiTV/releases/download/v${version}/thirdparty-linux.tar.xz && \
    tar xvf thirdparty-linux.tar.xz -C /code/server/ \
        --exclude=thirdparty/VCEEncC \
        --exclude=thirdparty/NVEncC \
        --exclude=thirdparty/QSVEncC && \
    mkdir -p /code/server/thirdparty/VCEEncC && \
    mkdir -p /code/server/thirdparty/NVEncC && \
    mkdir -p /code/server/thirdparty/QSVEncC && \
    touch /code/server/thirdparty/VCEEncC/VCEEncC.elf && \
    touch /code/server/thirdparty/NVEncC/NVEncC.elf && \
    touch /code/server/thirdparty/QSVEncC/QSVEncC.elf

# --------------------------------------------------------------------------------------------------------------
# クライアントをビルドするステージ
# --------------------------------------------------------------------------------------------------------------

FROM node:18 AS client-builder

COPY --from=downloader /code/client/ /code/client/

RUN cd /code/client/ && \
    yarn install --frozen-lockfile && \
    yarn build


# --------------------------------------------------------------------------------------------------------------
# メインのステージ
# --------------------------------------------------------------------------------------------------------------

FROM ubuntu:22.04

WORKDIR /code/server/

ENV TZ Asia/Tokyo

COPY --from=downloader /code/server/ /code/server/
COPY --from=client-builder /code/client/dist/ /code/client/dist/

ENV PIPENV_VENV_IN_PROJECT true
RUN /code/server/thirdparty/Python/bin/python -m pipenv sync --python="/code/server/thirdparty/Python/bin/python"

# CA 証明書を更新(Akebi が証明書をダウンロードする際エラーが出るため)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates 

# データベースを必要な場合にアップグレードし、起動
ENTRYPOINT /code/server/thirdparty/Python/bin/python -m pipenv run aerich upgrade && exec /code/server/.venv/bin/python KonomiTV.py
