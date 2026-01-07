# Используем свежую Ubuntu 22.04 (в ней GLIBC 2.35, всё заработает)
FROM ubuntu:22.04

# Обновляем систему и ставим SSH + curl (для установки Node.js)
RUN apt-get update && apt-get install -y openssh-server curl

# Настраиваем SSH (как было у rastasheep)
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Открываем порт
EXPOSE 22

# Запускаем SSH
CMD ["/usr/sbin/sshd", "-D"]
