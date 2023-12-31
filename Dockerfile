FROM python:3.11

ARG USERNAME=user-name-goes-here
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0400 /etc/sudoers.d/$USERNAME

VOLUME /workspace
WORKDIR /workspace

COPY requirements.txt .
RUN pip install -r requirements.txt

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

CMD ["bash"]
