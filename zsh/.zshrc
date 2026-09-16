# ============================================================
#  ~/.zshrc  —  跨平台 (macOS / Linux) + Oh My Zsh
#  工具栈: eza / bat / fd / fzf / zoxide / nvm
#  本文件由 ~/dotfiles/zsh/.zshrc 经 stow 链接过来，改这里就等于改 repo
#
#  设计原则：所有东西都先检测存在再启用，所以同一份文件
#  在 mac(brew) 和 Ubuntu(apt) 上都能直接跑，缺哪个工具就自动降级。
# ============================================================

# ----- 平台判定 ---------------------------------------------
case "$(uname -s)" in
  Darwin) IS_MAC=1   ;;
  Linux)  IS_LINUX=1 ;;
esac

# ----- PATH / Homebrew (放最前面) ---------------------------
if [[ -n $IS_MAC ]]; then
  # Apple Silicon 在 /opt/homebrew，Intel 在 /usr/local
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $_brew ]] && { eval "$($_brew shellenv)"; break; }
  done
  unset _brew
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  # Linux 上一般走 apt，装了 linuxbrew 才会命中这行
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 自动去重 PATH（zsh 特性，省得手动维护重复路径）
typeset -U path PATH

[[ -d $HOME/.lmstudio/bin ]] && path=("$HOME/.lmstudio/bin" $path)  # LM Studio CLI
[[ -d $HOME/.local/bin    ]] && path=("$HOME/.local/bin" $path)     # 个人脚本目录
# 说明：系统路径(/usr/bin 等)由 OS 启动时设好，不用手写。

# ----- Oh My Zsh --------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"   # 自带 git 分支 + 改动状态提示

# git 是 OMZ 自带；另两个要装到 $ZSH/custom/plugins（见文件末尾说明）
# zsh-syntax-highlighting 必须放最后，所以这里按顺序检测追加
plugins=(git)
for _p in zsh-autosuggestions zsh-syntax-highlighting; do
  [[ -d $ZSH/custom/plugins/$_p ]] && plugins+=($_p)
done
unset _p

[[ -r $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

# ----- 别名 (eza / bat / fd) --------------------------------
# Debian/Ubuntu 的包名有冲突：bat 装成 batcat、fd 装成 fdfind，这里统一抹平
if (( $+commands[batcat] )) && ! (( $+commands[bat] )); then
  alias bat='batcat'
  _BAT=batcat
elif (( $+commands[bat] )); then
  _BAT=bat
fi
[[ -n $_BAT ]] && alias cat="$_BAT"   # 带高亮的 cat（不想要就注释掉）

if (( $+commands[fdfind] )) && ! (( $+commands[fd] )); then
  alias fd='fdfind'
fi

if (( $+commands[eza] )); then
  # --icons 需要终端字体是 Nerd Font，否则会出方块/问号
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -la --icons=auto --git --group-directories-first'
  alias la='eza -a --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
  alias l='eza --icons=auto'
else
  alias ls='ls --color=auto'
  alias ll='ls -alF --color=auto'
  alias la='ls -A --color=auto'
  alias l='ls -CF --color=auto'
fi

alias grep='grep --color=auto'

# ----- fzf (模糊查找 + 快捷键) ------------------------------
# 提供 Ctrl+R 历史搜索 / Ctrl+T 文件搜索 / Alt+C 目录跳转
if (( $+commands[fzf] )); then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)                       # fzf >= 0.48
  else
    for _f in /usr/share/doc/fzf/examples/key-bindings.zsh \
              /usr/share/doc/fzf/examples/completion.zsh; do
      [[ -r $_f ]] && source $_f              # 老版本 Debian/Ubuntu 打包路径
    done
    unset _f
  fi
fi

# ----- nvm (Node 版本管理) ----------------------------------
# 两种安装方式都兼容：官方 curl 脚本装到 ~/.nvm，brew 装到 $HOMEBREW_PREFIX/opt/nvm。
# 不管哪种，node 版本数据目录都是 ~/.nvm。
export NVM_DIR="$HOME/.nvm"
if [[ -s $NVM_DIR/nvm.sh ]]; then
  \. "$NVM_DIR/nvm.sh"
  [[ -s $NVM_DIR/bash_completion ]] && \. "$NVM_DIR/bash_completion"
elif [[ -n $HOMEBREW_PREFIX && -s $HOMEBREW_PREFIX/opt/nvm/nvm.sh ]]; then
  [[ -d $NVM_DIR ]] || mkdir -p "$NVM_DIR"   # brew 版 nvm 需要这个目录先存在
  \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
  _nvm_comp="$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
  [[ -s $_nvm_comp ]] && \. "$_nvm_comp"
  unset _nvm_comp
fi

# ----- 机器专属配置 / 密钥 (不进 git) -----------------------
# API key、公司内网代理、只在某台机器上用的 alias 都放这里。
# ~/.zshrc.local 被 .gitignore 挡住了，永远不会被 commit。
[[ -r $HOME/.zshrc.local ]] && source "$HOME/.zshrc.local"

# ----- zoxide (智能 cd) —— 必须放在最后 --------------------
# zoxide 要求自己是最后初始化的（它接管 cd，被后面的东西覆盖就失效），
# 之前放中间会触发 "zoxide detected a possible configuration issue" 警告。
# 想保留原生 cd、只用 z 跳转，就把 --cmd cd 去掉。
(( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"

# ============================================================
#  新机器上手动补的东西：
#    oh-my-zsh: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#    插件:      git clone https://github.com/zsh-users/zsh-autosuggestions     $ZSH/custom/plugins/zsh-autosuggestions
#               git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH/custom/plugins/zsh-syntax-highlighting
#    工具:      mac  -> brew install eza bat fd fzf zoxide
#               apt  -> sudo apt install eza bat fd-find fzf zoxide
# ============================================================
