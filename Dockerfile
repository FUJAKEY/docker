FROM qemux/qemu-docker:latest

# 1. Устанавливаем инструменты, необходимые для скачивания
USER root
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    unzip \
    7zip \
    samba-client \
    wimlib \
    cabextract \
    libxml2-utils \
    xorriso \
    cdrkit

# 2. Скачиваем скрипты установки (так как оригинальный образ dockur недоступен)
WORKDIR /run
RUN wget -O entry.sh https://raw.githubusercontent.com/dockur/windows/master/src/entry.sh && \
    wget -O mido.sh https://raw.githubusercontent.com/dockur/windows/master/src/mido.sh && \
    chmod +x entry.sh mido.sh

# 3. === СКАЧИВАЕМ WINDOWS 11 ПРИ СБОРКЕ ===
# Внимание: Это скачает около 6 ГБ. Сборка может идти 10-15 минут.
RUN mkdir -p /storage && \
    /bin/bash ./mido.sh win11 && \
    mv ./*.iso /storage/fixed.iso && \
    echo "Windows 11 downloaded successfully"

# 4. Настройки системы
ENV VERSION="win11"
ENV RAM_SIZE="4G"
ENV CPU_CORES="2"
ENV DISK_SIZE="64G"

# Отключаем KVM (так как на Koyeb его нет)
ENV KVM="N"

# Указываем использовать уже скачанный файл
ENV ISO="/storage/fixed.iso"

# Открываем порты (Веб и RDP)
EXPOSE 8006 3389

# Запуск
ENTRYPOINT ["/usr/bin/tini", "-s", "--", "/bin/bash", "/run/entry.sh"]
