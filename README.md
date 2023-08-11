# docker-konomitv-lite
KonomiTV の省サイズなコンテナイメージ

## 概要
[公式のイメージ](https://github.com/tsukumijima/KonomiTV/pkgs/container/konomitv)には様々な環境でハードウェアエンコードに対応するためのライブラリ等が含まれています。
特に、Nvidia 環境向けに Cuda イメージをベースにしているため、
イメージのサイズが 1 GB を超えるほど非常に大きくなっています。

本リポジトリの目的は、ソフトウェアエンコードだけに対応する、
コンパクトなサイズの KonomiTV のイメージを提供することです。

このイメージをベースにして、独自ドメインの証明書を自動で発行してくれるようにした 
[docker-konomitv-acme](https://github.com/hrko/docker-konomitv-acme) も提供しています。

## リリース
イメージ一覧は[コンテナリポジトリ](https://github.com/hrko/docker-konomitv-lite/pkgs/container/konomitv-lite)をご覧ください。

最新版のリリースをプルするには以下のコマンドを実行してください。
```
docker pull ghcr.io/hrko/konomitv-lite:latest
```

## イメージサイズ比較
| イメージ名                          | イメージサイズ     |
| ----------------------------------- | ------------------ |
| ghcr.io/tsukumijima/konomitv:v0.7.1 | 1.7 GB (zst圧縮後) |
| ghcr.io/hrko/konomitv-lite:v0.7.1   | 269 MB (zst圧縮後) |

## 更新について
KonomiTV が新しいバージョンにアップデートされた際には、できる限り迅速に本イメージも追従させる予定です。もしもイメージの更新が滞っている場合は、お気軽にIssueを作成してご連絡ください。
