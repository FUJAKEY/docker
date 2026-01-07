# Используем стабильную версию с XFCE
FROM accetto/ubuntu-vnc-xfce-g3:latest

# Переходим в режим суперпользователя для настройки
USER 0

# 1. Устанавливаем SSH, Sudo и Curl
# 2. Чистим кэш
RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        curl \
        wget \
        nano \
        sudo \
        python3 \
        net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# === НАСТРОЙКА SSH ===
RUN mkdir /var/run/sshd
# Разрешаем вход root по SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# Отключаем строгую проверку (опционально, для удобства в тестах)
RUN sed -i 's/StrictModes yes/StrictModes no/' /etc/ssh/sshd_config

# === НАСТРОЙКА ПАРОЛЕЙ И SUDO ===
# Задаем пароль root:root
RUN echo 'root:root' | chpasswd

# Пользователь внутри контейнера называется 'headless'. 
# Мы даем ему тот же пароль 'root' и добавляем в группу sudo.
RUN echo 'headless:root' | chpasswd && usermod -aG sudo headless

# === СКРИПТ ЗАПУСКА ===
# Нам нужно запустить И ssh, И рабочий стол. Создаем скрипт запуска.
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "SSH started on port 22"\n\
# Запускаем оригинальный скрипт VNC\n\
/docker-startup/vnc_startup.sh --wait\n\
' > /start_custom.sh && chmod +x /start_custom.sh

# Настраиваем переменные VNC
ENV VNC_PW=mypassword

# Открываем порты: 6901 (Web VNC), 5901 (VNC Client), 22 (SSH)
EXPOSE 6901 5901 22

# Запускаем наш кастомный скрипт
ENTRYPOINT ["/start_custom.sh"]
