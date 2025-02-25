#!/bin/bash

# 开发环境设置脚本

# 创建符号链接到配置文件
setup_config_files() {
    echo "正在设置配置文件..."

    # 创建备份目录
    mkdir -p ~/backup_configs

    # 处理.tmux.conf
    if [ -f ~/.tmux.conf ]; then
        echo "备份现有的 .tmux.conf 到 ~/backup_configs/"
        cp ~/.tmux.conf ~/backup_configs/.tmux.conf.bak
    fi
    ln -sf $(pwd)/config/.tmux.conf ~/.tmux.conf

    # 处理.zshrc
    if [ -f ~/.zshrc ]; then
        echo "备份现有的 .zshrc 到 ~/backup_configs/"
        cp ~/.zshrc ~/backup_configs/.zshrc.bak
    fi
    ln -sf $(pwd)/config/.zshrc ~/.zshrc

    # 设置bash别名
    setup_bash_aliases
}

# 设置bash别名
setup_bash_aliases() {
    echo "正在设置bash别名..."

    # 检查是否已经在.zshrc中添加了别名引用
    if grep -q "source.*bash_aliases.sh" ~/.zshrc; then
        echo "Bash别名已在.zshrc中配置"
    else
        echo "正在将别名配置添加到.zshrc"
        echo "" >>~/.zshrc
        echo "# 加载自定义别名" >>~/.zshrc
        echo "if [ -f $(pwd)/config/bash_aliases.sh ]; then" >>~/.zshrc
        echo "    source $(pwd)/config/bash_aliases.sh" >>~/.zshrc
        echo "fi" >>~/.zshrc
    fi

    # 使zsh别名立即生效（如果zsh正在运行）
    if [ -f ~/.zshrc ] && [ -n "$ZSH_VERSION" ]; then
        source ~/.zshrc
    fi
}

# 安装和配置fzf
setup_fzf() {
    echo "正在安装和配置fzf..."

    # 检查fzf是否已安装
    if [ -d ~/.fzf ]; then
        echo "fzf已经安装，正在更新..."
        cd ~/.fzf && git pull && cd -
    else
        echo "正在安装fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi

    # 运行fzf安装脚本
    echo "正在运行fzf安装脚本..."
    ~/.fzf/install --all

    echo "fzf安装完成！"
}

# 安装和配置oh-my-zsh
setup_oh_my_zsh() {
    echo "正在安装和配置oh-my-zsh..."

    # 检查oh-my-zsh是否已安装
    if [ -d ~/.oh-my-zsh ]; then
        echo "oh-my-zsh已经安装"
    else
        echo "正在安装oh-my-zsh..."
        # 备份现有的.zshrc文件（如果存在）
        if [ -f ~/.zshrc ]; then
            echo "备份现有的.zshrc文件"
            cp ~/.zshrc ~/.zshrc.bak.$(date +%Y%m%d%H%M%S)
        fi

        # 使用curl安装oh-my-zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        # 恢复我们的自定义.zshrc文件
        if [ -f $(pwd)/config/.zshrc ]; then
            echo "应用自定义.zshrc配置"
            ln -sf $(pwd)/config/.zshrc ~/.zshrc
        fi
        # 将默认shell更改为zsh
        if [ "$SHELL" != "$(which zsh)" ]; then
            echo "正在将默认shell更改为zsh..."
            # 检查zsh是否已安装
            if command -v zsh >/dev/null 2>&1; then
                # 使用chsh命令更改默认shell
                chsh -s $(which zsh)
                echo "默认shell已更改为zsh，将在下次登录时生效"
            else
                echo "错误：未找到zsh，请先安装zsh后再尝试更改默认shell"
            fi
        else
            echo "zsh已经是默认shell"
        fi
    fi

    # 安装常用插件
    install_zsh_plugins

    echo "oh-my-zsh安装和配置完成！"
}

# 安装zsh插件
install_zsh_plugins() {
    echo "正在安装zsh插件..."

    # 安装zsh-autosuggestions
    if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
        echo "安装zsh-autosuggestions插件"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        echo "zsh-autosuggestions插件已安装"
    fi

    # 安装zsh-syntax-highlighting
    if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
        echo "安装zsh-syntax-highlighting插件"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        echo "zsh-syntax-highlighting插件已安装"
    fi

    echo "zsh插件安装完成！"
}

# 主函数
main() {
    echo "开始设置开发环境..."
    setup_config_files
    setup_fzf
    setup_oh_my_zsh
    echo "开发环境设置完成！"
    echo "请重新加载您的终端或执行 'source ~/.zshrc' 使所有更改生效"
}

# 执行主函数
main
