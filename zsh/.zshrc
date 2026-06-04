# ============================================================
#  ~/.zshrc  —  macOS (Apple Silicon) + Oh My Zsh
#  工具栈: eza / bat / fd / fzf / zoxide / nvm
# ============================================================

# ----- PATH / Homebrew (放最前面) ---------------------------
# Apple Silicon 的 Homebrew 在 /opt/homebrew，这行负责把它加进 PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# 自动去重 PATH（zsh 特性，省得手动维护重复路径）
typeset -U path PATH

# LM Studio CLI（原来重复了两次，这里只留一次）
export PATH="$HOME/.lmstudio/bin:$PATH"
# 个人脚本目录
export PATH="$HOME/.local/bin:$PATH"
# 说明：原来那一长串系统路径(/usr/bin、cryptex 等)不用手写，
# macOS 启动时会自动设置好，写死反而容易出错。

# ----- Oh My Zsh --------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"   # 这个主题自带 git 分支 + 改动状态提示

# 插件：git 是 OMZ 自带；后两个需要手动安装（见文件末尾说明）
# zsh-syntax-highlighting 必须放最后
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ----- 别名 (eza / bat / fd) --------------------------------
# mac 上 bat、fd 名字正常，不需要像 Debian 那样改名，所以删掉了
# 原来那两个 alias bat='bat' / alias fd='fd'（自己别名自己，没意义）
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -la --icons=auto --git --group-directories-first'
alias la='eza -a --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'
alias l='eza --icons=auto'        # 原来的 'ls -CF' eza 不认，已修正
alias cat='bat'                   # 带高亮的 cat（不想要就注释掉这行）

# 注：--icons 需要终端字体是 Nerd Font 才能正常显示，
# 否则会出现方块/问号，不想折腾就把各处 --icons=auto 删掉。

# ----- zoxide (智能 cd) -------------------------------------
# 用 cd 接管跳转，和你 Ubuntu 上的习惯一致；
# 想保留原生 cd、另用 z 命令跳转，就把下面改成: eval "$(zoxide init zsh)"
eval "$(zoxide init --cmd cd zsh)"

# ----- fzf (模糊查找 + 快捷键) ------------------------------
# 提供 Ctrl+R 历史搜索 / Ctrl+T 文件搜索 / Alt+C 目录跳转
# 需要 fzf >= 0.48
source <(fzf --zsh)

# ----- nvm (Node 版本管理) ----------------------------------
# 方式 A：官方 curl 脚本安装（默认在 ~/.nvm）—— 当前启用
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 方式 B：用 brew 安装 nvm（如走这条，注释掉上面方式 A，启用下面）
# export NVM_DIR="$HOME/.nvm"
# [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
# [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ----- 个人额外别名（放这里）-------------------------------
# alias gs='git status'
# alias ..='cd ..'
