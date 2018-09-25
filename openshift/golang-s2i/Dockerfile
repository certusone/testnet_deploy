# Custom S2I image for Golang
FROM registry.fedoraproject.org/f28/s2i-base

RUN dnf -y install golang inotify-tools protobuf-compiler rsync nmap-ncat dep ansible origin-clients && dnf -y clean all

# Environment setup
COPY scl_enable /opt/app-root/etc/scl_enable

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:0 ${APP_ROOT} && chmod -R ug+rwx ${APP_ROOT} && \
    rpm-file-permissions

# Copy S2I scripts
COPY s2i/ $STI_SCRIPTS_PATH
RUN chmod +x $STI_SCRIPTS_PATH/*

# OpenShift Ansible module
# TODO: don't even think about doing this in production
RUN pip install openshift

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage