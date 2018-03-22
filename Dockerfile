FROM ubuntu:16.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

# Set UTF-8 locale
RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Enable passwordless ssh authentication
RUN apt-get remove -y openssh-client
RUN apt-get update
RUN apt-get install -y openssh-server

RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

RUN service ssh start

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

# Add files.
ADD .bashrc /root/.bashrc

# Install Java 8
RUN cd opt && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz" &&\
   tar xzf jdk-8u161-linux-x64.tar.gz && rm -rf jdk-8u161-linux-x64.tar.gz

ENV JAVA_HOME /opt/jdk1.8.0_161
ENV PATH $PATH:/opt/jdk1.8.0_161/bin:/opt/jdk1.8.0_161/jre/bin:/etc/alternatives:/var/lib/dpkg/alternatives

RUN echo 'export JAVA_HOME="/opt/jdk1.8.0_161"' >> ~/.bashrc && \
    echo 'export PATH="$PATH:/opt/jdk1.8.0_161/bin:/opt/jdk1.8.0_161/jre/bin"' >> ~/.bashrc && \
    bash ~/.bashrc && cd /opt/jdk1.8.0_161/ && update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_161/bin/java 1
    
ENTRYPOINT ["/bin/bash"]
