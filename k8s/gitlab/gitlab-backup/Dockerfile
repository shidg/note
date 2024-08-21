FROM busybox
RUN mkdir /root/.kube
COPY kubectl /usr/bin/kubectl
COPY config /root/.kube
CMD ["sh"]
