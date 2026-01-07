# Используем стабильную версию
FROM accetto/ubuntu-vnc-xfce-g3:latest

# Переключаемся на root
USER 0

# Устанавливаем SSH, sudo и инструменты
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
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# === НАСТРОЙКА ПАРОЛЕЙ ===
# Пароль root:root
RUN echo 'root:root' | chpasswd
# Пароль пользователя headless:root (чтобы работал sudo внутри VNC)
RUN echo 'headless:root' | chpasswd && usermod -aG sudo headless

# === ИСПРАВЛЕННЫЙ СКРИПТ ЗАПУСКА ===
# Мы увидели в логах, что файл называется startup.sh
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "SSH started on port 22"\n\
\n\
echo "Starting VNC..."\n\
# Запускаем правильный скрипт от имени пользователя headless\n\
su headless -c "/dockerstartup/startup.sh --wait"\n\
' > /start_custom.sh && chmod +x /start_custom.sh

# Пароль для VNC (браузер)
ENV VNC_PW=mypassword

# Открываем порты
EXPOSE 6901 5901 22

# Запускаем
ENTRYPOINT ["/start_custom.sh"]
