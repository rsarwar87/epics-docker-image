FROM  	ubuntu:focal-20200423

LABEL 	maintainer="rashed.sarwar@ukaea.uk"
ENV DEBIAN_FRONTEND noninteractive

USER root
RUN apt update
RUN apt-get install -yq wget curl vim build-essential git python3 python3-pip python3-numpy \
      libhdf5-dev libx11-dev libxext-dev libxml2-dev libpng-dev libbz2-dev libfreetype6-dev xvfb 

RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
RUN ~/.fzf/install --all

RUN apt-get install -y python3-numpy \
                       python3-h5py \
                       python3-lxml \
                       python3-pint \
                       python3-ply \
                       python3-spyderlib \
                       python3-sphinx-rtd-theme \
                       graphviz \
                       python3-pyqtgraph \
                       python3-pytest ipython3



ENV LANG en_US.utf8
RUN apt install -yq libreadline-dev libraw1394-dev re2c openjdk-8-jre libmotif-dev locales libxmu-dev libxpm-dev xfonts-100dpi apt-file
RUN rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.utf8
RUN python3 -m pip install -U "caproto[complete]" 
RUN pip3 install pyepics 
RUN apt install perl
RUN rm -rf /var/lib/apt/lists/*



# INSTALLING BASE
ENV BASE_TAG R3.15.8
ENV INSTALL_PATH=/epics/
RUN mkdir /epics/ && mkdir /epics/base/
RUN git clone --branch $BASE_TAG https://github.com/epics-base/epics-base --depth=1 //epics/base/$BASE_TAG
RUN make -C $INSTALL_PATH/base/$BASE_TAG -j16 install >> /epics/base/$BASE_TAG/log.install
RUN rm -f /epics/base/base
RUN ln -s /epics/base/$BASE_TAG /epics/base/base
# INSTALLING EPICS7
ENV BASE_TAG R7.0.3.1
ENV INSTALL_PATH=/epics/
RUN git clone --branch $BASE_TAG https://github.com/epics-base/epics-base --depth=1 //epics/base/$BASE_TAG
RUN make -C $INSTALL_PATH/base/$BASE_TAG -j16 >> /epics/base/$BASE_TAG/log.install 
# set environment variables
RUN touch /epics/siteEnv
RUN echo "\# main EPICS env var" >> /epics/siteEnv
RUN echo "export EPICS_HOST_ARCH=linux-x86_64" >> /epics/siteEnv
RUN echo "export EPICS_ROOT=/epics" >> /epics/siteEnv
RUN echo "export EPICS_BASE=$INSTALL_PATH/base" >> /epics/siteEnv
RUN echo "export PATH=\${PATH}:\${EPICS_ROOT}/base/bin/\${EPICS_HOST_ARCH}:\${EPICS_ROOT}/extensions/bin/\${EPICS_HOST_ARCH}" >> /epics/siteEnv
RUN echo "\# channel access" >> /epics/siteEnv
RUN echo "export EPICS_CA_MAX_ARRAY_BYTES=100000000" >> /epics/siteEnv
RUN echo "export EPICS_CA_AUTO_ADDR_LIST=YES" >> /epics/siteEnv
RUN echo "export EPICS_CA_ADDR_LIST=" >> /epics/siteEnv
RUN git clone --branch extensions_20120904 --depth=1 https://github.com/epics-extensions/extensions /epics/base/extensions
RUN make -C /epics/base/extensions install


ENV SEQ_TAG 2.2.3-4
RUN git clone https://github.com/epicsdeb/seq --depth=1 --branch=debian/$SEQ_TAG /epics/module/seq/$SEQ_TAG
RUN ln -s /epics/module/seq/$SEQ_TAG /epics/module/seq/seq
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," /epics/module/seq/seq/configure/RELEASE
RUN make -C /epics/module/seq/seq/ install >> /epics/module/seq/seq/log.install

ENV IPAC_TAG 2.15
RUN git clone https://github.com/epics-modules/ipac --depth=1 --branch=$IPAC_TAG /epics/module/ipac/$IPAC_TAG
RUN ln -s /epics/module/ipac/$IPAC_TAG /epics/module/ipac/ipac
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," /epics/module/ipac/ipac/configure/RELEASE
RUN make -C /epics/module/ipac/ipac/ install >> /epics/module/ipac/ipac/log.install

ENV SSCAN_TAG R2-11
RUN git clone https://github.com/epics-modules/sscan --depth=1 --branch=$SSCAN_TAG /epics/module/sscan/$SSCAN_TAG
RUN ln -s /epics/module/sscan/$SSCAN_TAG /epics/module/sscan/sscan
RUN sed -i -e "/^SUPPORT\s*=/ s,=.*,=/epics/module," /epics/module/sscan/sscan/configure/RELEASE
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," /epics/module/sscan/sscan/configure/RELEASE
RUN sed -i -e "/^SNCSEQ\s*=/ s,=.*,=/epics/module/seq/seq," /epics/module/sscan/sscan/configure/RELEASE
RUN make -C /epics/module/sscan/sscan/ install >> /epics/module/sscan/sscan/log.install

ENV CALC_TAG R5-4-2
RUN git clone https://github.com/epics-modules/calc --depth=1 --branch=$CALC_TAG /epics/module/calc/$CALC_TAG
RUN ln -s /epics/module/calc/$CALC_TAG /epics/module/calc/calc
RUN sed -i -e "/^SNCSEQ\s*=/ s,=.*,=/epics/module/seq/seq," /epics/module/calc/calc/configure/RELEASE
RUN sed -i -e "/^SSCAN\s*=/ s,=.*,=/epics/module/sscan/sscan," /epics/module/calc/calc/configure/RELEASE
RUN sed -i -e "/^SUPPORT\s*=/ s,=.*,=/epics/module," /epics/module/calc/calc/configure/RELEASE
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," /epics/module/calc/calc/configure/RELEASE
RUN make -C /epics/module/calc/calc/ install >> /epics/module/calc/calc/log.install

ENV ANYS_TAG R4-39
RUN git clone https://github.com/epics-modules/asyn --depth=1 --branch=$ANYS_TAG /epics/module/asyn/$ANYS_TAG
RUN ln -s /epics/module/asyn/$ANYS_TAG /epics/module/asyn/asyn
RUN sed -i -e "/^SUPPORT\s*=/ s,=.*,=/epics/module," /epics/module/asyn/asyn/configure/RELEASE
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," /epics/module/asyn/asyn/configure/RELEASE
RUN sed -i -e "/^SNCSEQ\s*=/ s,=.*,=/epics/module/seq/seq," /epics/module/asyn/asyn/configure/RELEASE
RUN sed -i -e "/^IPAC\s*=/ s,=.*,=/epics/module/ipac/ipac," /epics/module/asyn/asyn/configure/RELEASE
RUN echo "SSCAN=/epics/module/sscan/sscan" >> /epics/module/asyn/asyn/configure/RELEASE
RUN echo "CALC=/epics/module/calc/calc" >> /epics/module/asyn/asyn/configure/RELEASE
RUN make -C /epics/module/asyn/asyn/ install >> /epics/module/asyn/asyn/log.install

ENV AUTOSAVE_TAG R5-10-1
RUN git clone https://github.com/epics-modules/autosave --depth=1 --branch=$AUTOSAVE_TAG /epics/module/autosave/$AUTOSAVE_TAG
RUN ln -s /epics/module/autosave/$AUTOSAVE_TAG /epics/module/autosave/autosave
RUN sed -i -e "/^SUPPORT\s*=/ s,=.*,=/epics/module," /epics/module/autosave/autosave/configure/RELEASE
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," /epics/module/autosave/autosave/configure/RELEASE
RUN make -C /epics/module/autosave/autosave/ install >> /epics/module/autosave/autosave/log.install

ENV BUSY_TAG R1-7-2
RUN git clone https://github.com/epics-modules/busy --depth=1 --branch=$BUSY_TAG /epics/module/busy/$BUSY_TAG
RUN ln -s /epics/module/busy/$BUSY_TAG /epics/module/busy/busy
RUN sed -i -e "/^AUTOSAVE\s*=/ s,=.*,=/epics/module/autosave/autosave," /epics/module/busy/busy/configure/RELEASE
RUN sed -i -e "/^SUPPORT\s*=/ s,=.*,=/epics/module," /epics/module/busy/busy/configure/RELEASE
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," /epics/module/busy/busy/configure/RELEASE
RUN sed -i -e "/^ASYN\s*=/ s,=.*,=/epics/module/asyn/asyn," /epics/module/busy/busy/configure/RELEASE
RUN sed -i -e "/^BUSY\s*=/ s,=.*,=/epics/module/busy/busy," /epics/module/busy/busy/configure/RELEASE
RUN make -C /epics/module/busy/busy/ install >> /epics/module/busy/busy/log.install


# Install AreaDetector
ENV AD_TAG R3-9
RUN git clone https://github.com/areaDetector/areaDetector --branch=$AD_TAG /epics/module/areaDetector/$AD_TAG --recursive --depth=1
RUN ln -s /epics/module/areaDetector/$AD_TAG /epics/module/areaDetector/areaDetector
ENV AD_PATH /epics/module/areaDetector/areaDetector/configure
RUN cp $AD_PATH/EXAMPLE_CONFIG_SITE.local $AD_PATH/CONFIG_SITE.local
RUN cp $AD_PATH/EXAMPLE_RELEASE_PRODS.local $AD_PATH/RELEASE_PRODS.local
RUN cp $AD_PATH/EXAMPLE_RELEASE_LIBS.local $AD_PATH/RELEASE_LIBS.local
#RUN cp $AD_PATH/EXAMPLE_RELEASE_PATHS.local $AD_PATH/EXAMPLE_RELEASE_PATHS.local
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," $AD_PATH/RELEASE_LIBS.local
RUN sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=/epics/base/base," $AD_PATH/RELEASE_PRODS.local
RUN sed -i -e "/^AREA_DETECTOR\s*=/ s,=.*,=/epics/module/areaDetector/areaDetector," $AD_PATH/RELEASE_LIBS.local
RUN sed -i -e "/^AREA_DETECTOR\s*=/ s,=.*,=/epics/module/areaDetector/areaDetector," $AD_PATH/RELEASE_PRODS.local
RUN sed -i -e "/^SUPPORT\s*=/ s,=.*,=/epics/module," $AD_PATH/RELEASE_LIBS.local
RUN sed -i -e "/^SUPPORT\s*=/ s,=.*,=/epics/module," $AD_PATH/RELEASE_PRODS.local
RUN sed -i -e "/^ASYN\s*=/ s,=.*,=/epics/module/asyn/asyn," $AD_PATH/RELEASE_LIBS.local
RUN sed -i -e "/^ASYN\s*=/ s,=.*,=/epics/module/asyn/asyn," $AD_PATH/RELEASE_PRODS.local
RUN sed -i -e "/^CALC\s*=/ s,=.*,=/epics/module/calc/calc," $AD_PATH/RELEASE_PRODS.local
RUN sed -i -e "/^AUTOSAVE\s*=/ s,=.*,=/epics/module/autosave/autosave," $AD_PATH/RELEASE_PRODS.local
RUN sed -i -e "/^BUSY\s*=/ s,=.*,=/epics/module/busy/busy," $AD_PATH/RELEASE_PRODS.local
RUN sed -i -e "/^SSCAN\s*=/ s,=.*,=/epics/module/sscan/sscan," $AD_PATH/RELEASE_PRODS.local

#RUN make -C $AD_PATH/../. -j16

RUN apt-get update -y
RUN apt-get install -y -qq iputils-ping sudo rsync apt-utils x11-utils expect

ARG   user=admin
RUN   adduser --disabled-password --gecos '' $user
RUN   echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN   echo "source ~/env.sh" >> /etc/skel/.bashrc
RUN   echo "source /epics/siteEnv" >> /etc/skel/.bashrc
RUN   echo "cd " >> /etc/skel/.bashrc 
RUN   usermod -a -G sudo $user
RUN   chmod +w /etc/sudoers 
RUN  sudo echo "Set disable_coredump false" >> /etc/sudo.conf
USER  $user
RUN   echo "sudo groupadd -g \${GROUP_ID} \${USER_NAME}" >> /home/$user/.bashrc 
RUN   echo "sudo adduser --no-create-home --disabled-password --gecos '' --shell /bin/bash -u=\${USER_ID} -gid \${GROUP_ID} \${USER_NAME}" >> /home/$user/.bashrc
RUN   echo "echo \"\${USER_NAME}:password\" | sudo chpasswd" >> /home/$user/.bashrc
#RUN   echo "sudo usermod -a -G nouserlogin \${USER_NAME}" >> /home/$user/.bashrc
RUN   echo "sudo usermod -a -G sudo \${USER_NAME}" >> /home/$user/.bashrc
RUN   echo "sudo cp /etc/skel/.* /home/\${USER_NAME}/." >> /home/$user/.bashrc 
RUN   echo "touch /home/$user/env.sh" >> /home/$user/.bashrc 
RUN   echo "echo \"export PWD=\${PWD} \" >> /home/$user/env.sh" >> /home/$user/.bashrc
RUN   echo "sudo mv /home/$user/env.sh /home/\${USER_NAME}/." >> /home/$user/.bashrc 
RUN   echo "sudo chown \${USER_NAME}:\${USER_NAME} /home/\${USER_NAME}" >> /home/$user/.bashrc 
RUN   echo "sudo su - \${USER_NAME}" >> /home/$user/.bashrc 


WORKDIR /home/$user/workspace
