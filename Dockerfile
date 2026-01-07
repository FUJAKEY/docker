# Используем базу LinuxServer Webtop (Ubuntu + XFCE + KasmVNC)
# Тег ubuntu-xfce сейчас базируется на Ubuntu Noble (24.04 LTS)
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Добавляем информацию о владельце (опционально)
LABEL maintainer="David"

# Переключаемся на root для установки обновлений
USER root

# 1. Обновляем списки пакетов
# 2. Делаем полный апгрейд системы (dist-upgrade) чтобы получить новейшие версии ПО
# 3. Устанавливаем базовые полезные утилиты (git, curl, python3 и т.д.)
# 4. Чистим кэш, чтобы образ весил меньше
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
    curl \
    wget \
    git \
    nano \
    python3 \
    python3-pip \
    htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Указываем переменные окружения по умолчанию (можно переопределить при запуске)
ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Jerusalem

# Открываем порт 3000 для веб-доступа (KasmVNC)
EXPOSE 3000

# Volume для сохранения данных пользователя (чтобы файлы не пропадали)
VOLUME /config
