# Используем стабильную версию
FROM accetto/ubuntu-vnc-xfce-g3:latest

# Переключаемся на root
USER 0

# === БАЗОВАЯ УСТАНОВКА ===
# Добавил gnupg (для ключей) и epiphany-browser (браузер)
RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        curl \
        wget \
        nano \
        sudo \
        python3 \
        net-tools \
        gnupg \
        epiphany-browser \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# === УСТАНОВКА ANTIGRAVITY (Google IDE) ===
# 1. Скачиваем ключ
# 2. Добавляем репозиторий
# 3. Обновляем списки и устанавливаем
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | tee /etc/apt/sources.list.d/antigravity.list && \
    apt-get update && \
    apt-get install -y antigravity

# === НАСТРОЙКА БРАУЗЕРА (FIX) ===
# Создаем обертку, чтобы браузер работал без ошибок "bwrap" и "sandbox"
RUN echo '#!/bin/bash\nWEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1 /usr/bin/epiphany "$@"' > /usr/local/bin/epiphany-fix && \
    chmod +x /usr/local/bin/epiphany-fix && \
    # Делаем его браузером по умолчанию
    update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/epiphany-fix 200 && \
    update-alternatives --set x-www-browser /usr/local/bin/epiphany-fix

# === НАСТРОЙКА SSH ===
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# === НАСТРОЙКА ПАРОЛЕЙ ===
RUN echo 'root:root' | chpasswd
RUN echo 'headless:root' | chpasswd && usermod -aG sudo headless

# === ИСПРАВЛЕННЫЙ СКРИПТ ЗАПУСКА ===
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "SSH started on port 22"\n\
\n\
echo "Fixing permissions..."\n\
chown -R headless:headless /home/headless\n\
chown -R headless:headless /dockerstartup\n\
\n\
echo "Starting VNC..."\n\
su headless -c "/dockerstartup/startup.sh --wait"\n\
' > /start_custom.sh && chmod +x /start_custom.sh

# Пароль VNC
ENV VNC_PW=mypassword

EXPOSE 5901 22 6901

ENTRYPOINT ["/start_custom.sh"]
