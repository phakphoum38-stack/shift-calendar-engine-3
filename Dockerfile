FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      git \
      make \
      unzip \
      zip \
      curl \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

CMD ["bash"]
