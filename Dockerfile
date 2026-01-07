# Используем стабильную версию
FROM accetto/ubuntu-vnc-xfce-g3:latest

# Переключаемся на root
USER 0

# Устанавливаем SSH и прочее
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
RUN echo 'root:root' | chpasswd
RUN echo 'headless:root' | chpasswd && usermod -aG sudo headless

# === ИСПРАВЛЕННЫЙ СКРИПТ ЗАПУСКА ===
# Добавлена секция Fix Permissions, чтобы исправить ошибку "Permission denied"
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "SSH started on port 22"\n\
\n\
echo "Fixing permissions..."\n\
# Возвращаем права пользователю headless на его домашнюю папку и папку запуска\n\
chown -R headless:headless /home/headless\n\
chown -R headless:headless /dockerstartup\n\
\n\
echo "Starting VNC..."\n\
su headless -c "/dockerstartup/startup.sh --wait"\n\
' > /start_custom.sh && chmod +x /start_custom.sh

# Пароль VNC
ENV VNC_PW=mypassword

EXPOSE 6901 5901 22

ENTRYPOINT ["/start_custom.sh"]
