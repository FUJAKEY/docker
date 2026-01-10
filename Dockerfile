FROM dockur/windows:latest

# Настройки для Windows 10 (она легче, чем 11)
ENV VERSION="win10"
ENV RAM_SIZE="4G"
ENV CPU_CORES="2"
ENV DISK_SIZE="40G"

# Открываем порт для веб-просмотра (8006) и RDP (3389)
EXPOSE 8006 3389

# ВАЖНО: Остановить контейнер, если будет сбой
STOPSIGNAL SIGINT
