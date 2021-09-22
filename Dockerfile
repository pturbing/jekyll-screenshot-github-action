FROM python

RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    fonts-noto-color-emoji \
    gnupg \
    ruby-full \
    build-essential \
    zlib1g-dev \
    && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y \
    google-chrome-stable \
    --no-install-recommends \
    && gem install jekyll bundler

# Google Chrome doesn't run from the root user.
RUN groupadd chrome && useradd --uid=1001 -g chrome -s /bin/bash -G audio,video chrome \
    && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome


ADD ./requirements.txt .
RUN python -m pip install -r requirements.txt

USER chrome
ENV HOME /home/chrome
WORKDIR /home/chrome
ADD ./screenshot.py .
ADD ./override-home.sh .
RUN python -c '__import__("pyppeteer").chromium_downloader.download_chromium()'

CMD ["/home/chrome/override-home.sh", "/home/chrome/screenshot.py"]
