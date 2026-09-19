#!/usr/bin/env bash
# ============================================================
#  dotfiles/bootstrap.sh — 新机器一键初始化 (macOS / Debian·Ubuntu)
#
#  用法:
#    git clone git@github.com:RunxinShao/dotfiles.git ~/dotfiles
#    bash ~/dotfiles/bootstrap.sh
#
#  幂等：重复跑不会坏，已装好的会跳过。
#  装完后 exec zsh 或重开窗口生效。
# ============================================================
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PACKAGES=(zsh bash git)   # 要 stow 到 $HOME 的子目录

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

case "$(uname -s)" in
  Darwin) OS=mac   ;;
  Linux)  OS=linux ;;
  *) echo "不支持的系统: $(uname -s)" >&2; exit 1 ;;
esac

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

# ---------- 1. 包管理器装工具 -------------------------------
install_tools_mac() {
  if ! have brew; then
    warn "没有 Homebrew，先装: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    return 1
  fi
  log "brew install 工具栈"
  brew install eza bat fd fzf zoxide stow gh git zsh
}

install_tools_linux() {
  have apt-get || { warn "只自动支持 apt 系，其它发行版请手动装: eza bat fd fzf zoxide stow gh"; return 1; }
  log "apt install 工具栈"
  $SUDO apt-get update -qq
  # Debian/Ubuntu 包名和 mac 不一样: bat->batcat, fd->fdfind (.zshrc 里已经做了 alias 抹平)
  $SUDO apt-get install -y --no-install-recommends \
    zsh git curl wget ca-certificates stow \
    eza bat fd-find fzf zoxide
  install_gh_apt
}

# gh: Ubuntu 仓库里的版本很旧(2.46)，优先用 GitHub 官方 apt 源拿最新版
install_gh_apt() {
  if have gh; then log "gh 已装: $(gh --version | head -1)"; return 0; fi
  log "添加 GitHub CLI 官方 apt 源"
  local keyring=/etc/apt/keyrings/githubcli-archive-keyring.gpg
  if $SUDO mkdir -p -m 755 /etc/apt/keyrings \
     && wget -nv -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | $SUDO tee "$keyring" >/dev/null \
     && $SUDO chmod go+r "$keyring" \
     && echo "deb [arch=$(dpkg --print-architecture) signed-by=$keyring] https://cli.github.com/packages stable main" \
        | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null \
     && $SUDO apt-get update -qq; then
    $SUDO apt-get install -y gh
  else
    warn "官方源加失败，退回发行版自带的 gh（版本较旧）"
    $SUDO apt-get install -y gh
  fi
}

# ---------- 2. Oh My Zsh + 插件 -----------------------------
install_omz() {
  export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  if [[ -d $ZSH ]]; then
    log "oh-my-zsh 已存在，跳过"
  else
    log "安装 oh-my-zsh"
    # --unattended: 不自动改 shell、不自动进 zsh，也不会覆盖我们 stow 过来的 .zshrc
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  local repo
  for repo in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
    local name="${repo##*/}" dir="$ZSH/custom/plugins/${repo##*/}"
    if [[ -d $dir ]]; then
      log "插件 $name 已存在，跳过"
    else
      log "克隆插件 $name"
      git clone --depth=1 "https://github.com/$repo" "$dir"
    fi
  done
}

# ---------- 3. Claude Code ----------------------------------
# 官方原生安装器，装到 ~/.local/bin（.zshrc 已把这个目录加进 PATH），不需要 node
install_claude() {
  if have claude; then
    log "claude 已装: $(claude --version 2>/dev/null || echo 未知版本)"
    return 0
  fi
  if [[ -x $HOME/.local/bin/claude ]]; then
    log "claude 已在 ~/.local/bin（当前 shell 的 PATH 还没刷新）"
    return 0
  fi
  log "安装 Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
}

# ---------- 4. stow 链接 dotfiles ---------------------------
link_dotfiles() {
  have stow || { warn "没有 stow，跳过链接"; return 1; }
  log "stow: ${STOW_PACKAGES[*]} -> $HOME"
  # --restow 先取消再重建，已经链好的机器重复跑也不会报冲突
  stow -d "$DOTFILES" -t "$HOME" --restow "${STOW_PACKAGES[@]}"
}

# ---------- 5. 机器专属配置文件 -----------------------------
# ~/.zshrc.local 放 API key / 代理 / 单机 alias，被 .gitignore 挡着，不进 repo
seed_local_config() {
  local f="$HOME/.zshrc.local"
  if [[ -e $f ]]; then
    log "$f 已存在，不动它"
    return 0
  fi
  log "创建 $f 模板"
  cat > "$f" <<'LOCAL'
# ~/.zshrc.local — 本机专属配置 / 密钥（不进 git）
# 由 ~/.zshrc 末尾自动 source。

# 注意: 设了 ANTHROPIC_API_KEY 的话 Claude Code 会走 API 计费而不是订阅登录。
# 用订阅就别设这个变量，直接跑 `claude` 走浏览器登录。
# export ANTHROPIC_API_KEY="..."
LOCAL
  chmod 600 "$f"
}

# ---------- 主流程 ------------------------------------------
log "机器: $OS  |  dotfiles: $DOTFILES"
if [[ $OS == mac ]]; then install_tools_mac || true; else install_tools_linux || true; fi
install_omz
link_dotfiles || true
seed_local_config
install_claude

echo
log "完成。生效方式: exec zsh   （或直接重开一个窗口）"
[[ $OS == linux && $SHELL != */zsh ]] && warn "当前登录 shell 是 $SHELL，要改成 zsh: chsh -s \$(command -v zsh)"
have gh && ! gh auth status >/dev/null 2>&1 && warn "gh 还没登录: gh auth login"
have claude || warn "claude 装完后需要新 shell 才能在 PATH 里找到"
exit 0
