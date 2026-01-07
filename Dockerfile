# Используем стабильную версию
FROM accetto/ubuntu-vnc-xfce-g3:latest

# Переключаемся на root
USER 0

# Устанавливаем SSH, sudo и прочее
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
# Пароль headless:root (для sudo внутри VNC)
RUN echo 'headless:root' | chpasswd && usermod -aG sudo headless

# === УМНЫЙ СКРИПТ ЗАПУСКА ===
# Мы используем переменную $STARTUPDIR, чтобы точно найти путь
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "SSH started on port 22"\n\
\n\
# Проверяем, где лежит скрипт запуска и запускаем его от юзера headless\n\
if [ -f "$STARTUPDIR/vnc_startup.sh" ]; then\n\
    su headless -c "$STARTUPDIR/vnc_startup.sh --wait"\n\
elif [ -f "/dockerstartup/vnc_startup.sh" ]; then\n\
    su headless -c "/dockerstartup/vnc_startup.sh --wait"\n\
else\n\
    echo "Error: Startup script not found! Listing dirs:"\n\
    ls -R /dockerstartup\n\
fi\n\
' > /start_custom.sh && chmod +x /start_custom.sh

# Пароль для VNC
ENV VNC_PW=mypassword

# Открываем порты
EXPOSE 6901 5901 22

# Запускаем
ENTRYPOINT ["/start_custom.sh"]
