FROM alpine:3.12
RUN apk update && apk add bash wireguard-tools openssh python3 py3-pip make curl tar
RUN curl -L https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip --output terraform.zip \
  && unzip terraform.zip \
  && mv terraform /usr/local/bin \
  && rm terraform.zip
RUN pip install click
WORKDIR /root
COPY scripts ./scripts
COPY vultr ./vultr
WORKDIR /root/vultr
RUN terraform init
WORKDIR /root
COPY entrypoint.sh /usr/local/bin
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "build" ]
