#!/bin/bash

# 请将下面的公钥内容替换为你的公钥
PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCt2ERxlXuG8W4dZDzqCHHuP/Bw/NAX8qKlJKnBQoGVN+/aNNDwikHg+6AOzVWLIdRzOPHjVwfNTdaJx63IDAdKTja840I+q3P+f3X5iriBCtACQSYDgKqbiLcfyh937rftONQ19Kv+7/4dXUlnBhysL/gOohQIfrUceJ7PTPAzmfuwKyUdouQ808kjy5wZe5tN0JI4VjREa1bDK8+FIZGTZTC8Vj+fcx8wA7mVGcOWukHCp311k13rAwy5SEtMeLZ34PxNKwY3pwCA31vPqaZOp7lHe2QSs/suaNTxWx8W173hhxmOs8ieME8mec7KVzRf5nNge0n5eri4ELVLbGWP"

# 设置SSH目录和authorized_keys文件的路径
SSH_DIR="$HOME/.ssh"
AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"

# 检查~/.ssh目录是否存在，如果不存在则创建
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# 如果authorized_keys文件不存在则创建，并将公钥追加到文件中
if [ ! -f "$AUTHORIZED_KEYS_FILE" ]; then
    touch "$AUTHORIZED_KEYS_FILE"
    chmod 600 "$AUTHORIZED_KEYS_FILE"
fi

# 将公钥追加到authorized_keys文件中
echo "$PUBLIC_KEY" >> "$AUTHORIZED_KEYS_FILE"

# 启用密钥登录
sed -i '/^#PubkeyAuthentication/s/^#//' /etc/ssh/sshd_config
sed -i '/^#AuthorizedKeysFile	.ssh\/authorized_keys .ssh\/authorized_keys2/s/^#//' /etc/ssh/sshd_config

# 禁用密码登录
sed -i '/^PasswordAuthentication/s/yes/no/' /etc/ssh/sshd_config

# 检查PermitRootLogin的配置
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
    sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
elif grep -q "^PermitRootLogin without-password" /etc/ssh/sshd_config; then
    sed -i 's/^PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
elif ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

# 重载SSH服务
service ssh reload

echo "公钥已成功添加到authorized_keys文件中，并且已启用密钥登录，禁用密码登录。"
