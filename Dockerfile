FROM node:18-bullseye-slim

ENV MYPATH /root/uccs
WORKDIR $MYPATH
ENV SHELL /bin/bash

ADD z /root/.z_jump 
# RUN  apt-get update && apt-get install -y sudo zsh tree vim exa fzf
RUN apt-get update && apt-get install -y sudo curl zsh git tree vim exa fzf openssh-server silversearcher-ag fd-find rsync \
    && git config --global init.defaultBranch main \
    && yes | ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key 

# zsh
RUN sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"; \
    sh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'; \
    sh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'; \
    echo 'export ZSH=$HOME/.oh-my-zsh' >> /root/.zshrc; \
    echo 'ZSH_THEME="robbyrussell"' >> /root/.zshrc; \
    echo 'plugins=(git zsh-syntax-highlighting zsh-autosuggestions)' >> /root/.zshrc; \
    echo 'source $ZSH/oh-my-zsh.sh' >> /root/.zshrc
ENV SHELL /bin/zsh
# end

VOLUME ["/root/.local/share/pnpm"]
ENV PNPM_HOME /root/.local/share/pnpm \
    && PATH $PNPM_HOME:$PATH
RUN npm config set registry=https://registry.npmmirror.com \ 
    && npm i -g pnpm \ 
    && pnpm setup \ 
    && pnpm config set store-dir $PNPM_HOME 

# dotfiles
ADD bashrc /root/.bashrc
RUN echo '[ -f /root/.bashrc ] && source /root/.bashrc' >> /root/.zshrc; \
    echo '[ -f /root/.zshrc.local ] && source /root/.zshrc.local' >> /root/.zshrc
RUN mkdir -p /root/.config; \
    touch /root/.config/.profile; ln -s /root/.config/.profile /root/.profile; \
    touch /root/.config/.gitconfig; ln -s /root/.config/.gitconfig /root/.gitconfig; \
    touch /root/.config/.zsh_history; ln -s /root/.config/.zsh_history /root/.zsh_history; \
    touch /root/.config/.z; ln -s /root/.config/.z /root/.z; \
    # touch /root/.config/.rvmrc; ln -s /root/.config/.rvmrc /root/.rvmrc; \
    touch /root/.config/.bashrc; ln -s /root/.config/.bashrc /root/.bashrc.local; \
    touch /root/.config/.zshrc; ln -s /root/.config/.zshrc /root/.zshrc.local;
# end