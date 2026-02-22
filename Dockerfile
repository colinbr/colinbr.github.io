FROM ruby:slim

# Set metadata
LABEL authors="Amir Pourmand,George Araújo" \
      description="Docker image for al-folio academic template" \
      maintainer="Amir Pourmand"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    EXECJS_RUNTIME=Node \
    JEKYLL_ENV=production \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Install system dependencies with cache optimization
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    imagemagick \
    inotify-tools \
    locales \
    nodejs \
    procps \
    python3-pip \
    zlib1g-dev && \
    pip install --no-cache-dir --upgrade --break-system-packages nbconvert && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

# Configure locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Create jekyll directory
RUN mkdir -p /srv/jekyll

WORKDIR /srv/jekyll

# Copy Gemfile files before bundle install for better caching
COPY Gemfile Gemfile.lock ./

# Install jekyll and bundle dependencies
RUN gem install --no-document jekyll bundler && \
    bundle install --no-cache

# Copy entry point script
COPY bin/entry_point.sh /tmp/entry_point.sh
RUN chmod +x /tmp/entry_point.sh

EXPOSE 8080

CMD ["/tmp/entry_point.sh"]
