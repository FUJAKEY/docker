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

# === НАСТРОЙКА SSH НА ПОРТУ 5901 ===
RUN mkdir /var/run/sshd
# Разрешаем вход root
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# МЕНЯЕМ ПОРТ SSH С 22 НА 5901
RUN sed -i 's/#Port 22/Port 5901/' /etc/ssh/sshd_config
# На случай если строка выглядит иначе, добавляем принудительно
RUN echo "Port 5901" >> /etc/ssh/sshd_config

# === НАСТРОЙКА ПАРОЛЕЙ ===
RUN echo 'root:root' | chpasswd
RUN echo 'headless:root' | chpasswd && usermod -aG sudo headless

# === ПЕРЕНОС VNC НА 5902 ===
# Это заставит VNC сервер уйти с порта 5901 на 5902, чтобы освободить место для SSH
ENV VNC_PORT=5902
# Порт для браузера оставляем стандартным (или 6901)
ENV NO_VNC_PORT=6901

# === СКРИПТ ЗАПУСКА ===
RUN echo '#!/bin/bash\n\
# Стартуем SSH (он теперь прочитает конфиг и встанет на 5901)\n\
service ssh start\n\
echo "SSH started on port 5901"\n\
\n\
echo "Fixing permissions..."\n\
chown -R headless:headless /home/headless\n\
chown -R headless:headless /dockerstartup\n\
\n\
echo "Starting VNC (on port 5902)..."\n\
su headless -c "/dockerstartup/startup.sh --wait"\n\
' > /start_custom.sh && chmod +x /start_custom.sh

# Пароль для VNC
ENV VNC_PW=mypassword

# Открываем порты: 6901 (Web), 5901 (теперь SSH), 5902 (VNC Direct)
EXPOSE 6901 5901 5902

ENTRYPOINT ["/start_custom.sh"]
