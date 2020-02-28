#  The image to run ssh in a container.

FROM alpine:20200122

LABEL maintainer="me@ikevinshah.com"

# Stopping the container
STOPSIGNAL SIGTERM

# To use a custom user and a custom password
ARG user=ssh

# To set custom password
ARG password=Som3rand0mp@ssw0rd

ENV user=$user \
    password=$password

RUN apk add --update bash bash-completion openssh \
    && echo "Create ssh group" \
    && addgroup -g 122 ssh \
    && echo "Creating $user user" \
    && adduser -u 1022 -G ssh -h /home/$user -s /bin/bash -D $user \
    && mkdir -p /home/$user/.ssh \
    && chown -R $user:ssh /home/$user/.ssh \
    && chmod -R u+rwx,g+rs,o-rwx /home/$user/.ssh \
    && echo "Cleaning cache "  \
    && rm  -rf /tmp/* /var/cache/apk/* \
    && echo "Generating public/private rsa key pair."  \
    && ssh-keygen -q -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" -t rsa \
    && echo "Generating public/private dsa key pair."  \
    && ssh-keygen -q -b 1024 -f /etc/ssh/ssh_host_dsa_key -N "" -t dsa \
    && echo "Generating public/private ecdsa key pair."  \
    && ssh-keygen -q -b 521 -f /etc/ssh/ssh_host_ecdsa_key -N "" -t ecdsa \
    && echo "Generating public/private ed25519 key pair."  \
    && ssh-keygen -q -b 4096 -f /etc/ssh/ssh_host_ed25519_key -N "" -t ed25519 \
    && echo "Welcome!" > /etc/motd \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "# Listen on this port" >> /etc/ssh/sshd_config \
    && echo "Port 22" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "SyslogFacility AUTH" >> /etc/ssh/sshd_config \
    && echo "LogLevel INFO" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "# Auth keys" >> /etc/ssh/sshd_config \
    && echo "AuthorizedKeysFile /home/ssh/.ssh/authorized_keys" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "#HostKeys" >> /etc/ssh/sshd_config \
    && echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config \
    && echo "HostKey /etc/ssh/ssh_host_dsa_key" >> /etc/ssh/sshd_config \
    && echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config \
    && echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "# Disable Root" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin No" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "#Allow only specified user and ssh group" >> /etc/ssh/sshd_config \
    && echo "AllowGroups ssh" >> /etc/ssh/sshd_config \
    && echo "AllowUsers $user" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "# Permit password logins (unsecure)" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
    && echo "PidFile /var/run/sshd.pid" >> /etc/ssh/sshd_config;

# To-do in future, run ssh daemon with ssh(non-root)
# USER ssh

EXPOSE 22

CMD ["/bin/bash","-c","echo \"Changing $user's password to '$password'\" && echo \"$user:$password\" | chpasswd && echo 'Starting sshd' && /usr/sbin/sshd -D -e"]
