# Используем базу Ubuntu 24.04 (Noble) с настроенным VNC и noVNC
FROM accetto/ubuntu-vnc-xfce-g3:noble

# Переключаемся на root для установки программ
USER 0

# Обновляем систему до последних версий и ставим нужный софт
# Сюда можно дописать любые программы, которые тебе нужны (например, firefox, python3)
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

# (Опционально) Устанавливаем пароль VNC по умолчанию
# Если не хочешь хардкодить пароль, удали эту строку и передавай его при запуске
ENV VNC_PW=mypassword

# Возвращаемся к пользователю по умолчанию (headless) для безопасности
USER 1001

# Открываем порты:
# 6901 - для входа через браузер (noVNC)
# 5901 - для обычного VNC клиента
EXPOSE 6901 5901
