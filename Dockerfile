# Используем стабильную версию
FROM accetto/ubuntu-vnc-xfce-g3:latest

# Переключаемся на root (и останемся на нем для старта сервисов)
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
# Разрешаем вход root
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# === НАСТРОЙКА ПАРОЛЕЙ ===
# Пароль root
RUN echo 'root:root' | chpasswd

# Пароль пользователя headless (для VNC) и добавление его в sudo
RUN echo 'headless:root' | chpasswd && usermod -aG sudo headless

# === СКРИПТ ЗАПУСКА ===
# 1. Запускаем SSH (от root)
# 2. Запускаем VNC (переключаясь на пользователя headless, так безопаснее для GUI)
# Обрати внимание: путь исправлен на /docker-startup/startup.sh
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "SSH started on port 22"\n\
# Передаем управление скрипту VNC от имени пользователя headless\n\
su headless -c "/docker-startup/startup.sh --wait"\n\
' > /start_custom.sh && chmod +x /start_custom.sh

# Пароль для VNC (браузер)
ENV VNC_PW=mypassword

# Открываем порты
EXPOSE 6901 5901 22

# Запускаем кастомный скрипт
ENTRYPOINT ["/start_custom.sh"]
