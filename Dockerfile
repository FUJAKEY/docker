# Используем тег latest (стабильная версия) вместо noble
FROM accetto/ubuntu-vnc-xfce-g3:latest

# Переключаемся на root для установки программ
USER 0

# Обновляем систему и ставим нужный софт
RUN apt-get update && \
    apt-get install -y \
        wget \
        curl \
        git \
        nano \
        python3 \
        python3-pip \
        htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Задаем пароль (можно поменять mypassword на свой)
ENV VNC_PW=mypassword

# Возвращаемся к пользователю по умолчанию
USER 1001

# Открываем порты для браузера и VNC
EXPOSE 6901 5901
