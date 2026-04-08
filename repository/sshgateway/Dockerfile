FROM alpine:3.19

RUN apk add --no-cache openssh python3 py3-pip linux-pam && \
    pip3 install --no-cache-dir pymysql --break-system-packages && \
    ssh-keygen -A && \
    addgroup -S ltpda-users

COPY sshd_config /etc/ssh/sshd_config
COPY pam_ltpda /etc/pam.d/sshd
COPY validate_auth.py /usr/local/bin/validate_auth.py
RUN chmod +x /usr/local/bin/validate_auth.py

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
