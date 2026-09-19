# dotfiles

一套适用于 macOS 和 Debian/Ubuntu 的个人 Shell 配置，使用 stow 把 `zsh`、`bash`、`git` 的配置链接到 `$HOME`。

最基础的安装方式放在最前面：

```bash
git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

如果还没配 SSH，可以用 HTTPS：

```bash
git clone https://github.com/RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

---

## 文件和目录说明

```text
dotfiles/
├── bootstrap.sh       # 新机器初始化脚本
├── zsh/
│   └── .zshrc         # Zsh 配置
├── bash/
│   └── .bashrc        # Bash 配置
├── git/
│   ├── .gitconfig     # Git 配置
│   └── .gitignore_global # Git 全局忽略规则
└── .gitignore         # 仓库自身的忽略规则
```

### `bootstrap.sh`

新机器上的一键初始化脚本，主要负责“安装和准备环境”：

- 根据系统使用 Homebrew 或 `apt` 安装工具
- 安装 Zsh、Git、Stow、fzf、zoxide、eza、bat、fd、gh 等
- 安装 Oh My Zsh 和 Zsh 插件
- 安装 Claude Code
- 使用 Stow 把配置文件链接到 `$HOME`
- 创建 `~/.zshrc.local`，保存本机专属配置

它通常只需要在新机器上执行一次；以后更新配置时也可以重新执行。

### `zsh/`

存放 Zsh 配置。`zsh/.zshrc` 会在启动 Zsh 时加载，用来设置：

- Oh My Zsh 和插件
- alias
- `fzf`、`zoxide`、`nvm`、GitHub CLI 补全
- 本机的 `~/.zshrc.local`

它负责“启动时配置环境”，不负责安装软件。

### `bash/`

存放 Bash 配置。`bash/.bashrc` 负责 Bash 启动时的：

- alias 和命令补全
- `fzf`、`nvm`、`zoxide` 配置
- 本机的 `~/.bashrc.local`

### `git/`

存放 Git 相关配置：

- `.gitconfig`：Git 用户名、邮箱和全局忽略文件位置
- `.gitignore_global`：所有 Git 仓库通用的忽略规则

### `.gitignore`

只用于忽略当前 dotfiles 仓库中的文件，例如日志、`.DS_Store` 和 `*.local` 文件，避免把本机配置或敏感信息提交到 Git。

---

## 配置文件链接关系

执行 `bootstrap.sh` 后，Stow 会把仓库中的配置链接到用户主目录：

```text
~/.zshrc            -> ~/dotfiles/zsh/.zshrc
~/.bashrc           -> ~/dotfiles/bash/.bashrc
~/.gitconfig        -> ~/dotfiles/git/.gitconfig
~/.gitignore_global -> ~/dotfiles/git/.gitignore_global
```

因此，Shell 实际加载的是 `$HOME` 下的文件，但文件内容由 `~/dotfiles` 仓库统一管理。修改配置后，可以直接提交仓库中的对应文件。

检查链接是否生效：

```bash
ls -l ~/.zshrc ~/.bashrc ~/.gitconfig ~/.gitignore_global
```

---

## 支持的系统

- macOS
- Debian / Ubuntu

## `bootstrap.sh` 会自动做什么

- 安装常用工具：`zsh`, `git`, `stow`, `fzf`, `zoxide`, `eza`, `bat`, `fd`, `gh`
- 安装 Oh My Zsh 和插件
- 安装 Claude Code
- 通过 `stow` 把配置链接到 `$HOME`
- 创建 `~/.zshrc.local`，用于放本机私密配置，不会提交到仓库

## macOS 详细步骤

```bash
# 1. 安装开发者工具（如果还没装）
xcode-select --install

# 2. 安装 Homebrew（如果还没装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. 安装 dotfiles
git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

## Debian / Ubuntu 详细步骤

```bash
sudo apt-get update
sudo apt-get install -y git curl ca-certificates sudo

git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

如果当前 shell 不是 zsh：

```bash
chsh -s "$(command -v zsh)"
```

## GitHub SSH 登录（如果用 SSH clone）

```bash
ssh-keygen -t ed25519 -C "shaorunxinnb@gmail.com"
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"
cat "$HOME/.ssh/id_ed25519.pub"
```

把输出的公钥复制到 GitHub：

- GitHub → Settings → SSH and GPG keys → New SSH key

然后测试：

```bash
ssh -T git@github.com
```

## 本机专属配置

`bootstrap.sh` 会创建：

```bash
~/.zshrc.local
```

把本机私密内容放进去，比如 API key、代理、特殊 alias：

```bash
${EDITOR:-vi} "$HOME/.zshrc.local"
```

示例：

```bash
# export ANTHROPIC_API_KEY="..."
# export HTTP_PROXY="http://127.0.0.1:7890"
# alias cproj='cd ~/projects/myproject'
```

## 更新配置

```bash
cd "$HOME/dotfiles"
git pull --ff-only
bash ./bootstrap.sh
exec zsh
```

如果只是同步 stow 链接：

```bash
cd "$HOME/dotfiles"
stow -d "$HOME/dotfiles" -t "$HOME" --restow zsh bash git
```

## 常见问题

### 1. `git clone` 报 Permission denied (publickey)

说明 SSH key 没配好，改用 HTTPS 或先配置 SSH。

### 2. 当前终端还没切到 zsh

```bash
exec zsh
```

### 3. `claude` 命令找不到

```bash
exec zsh
command -v claude
```

### 4. `zsh` 配置没生效

```bash
cd "$HOME/dotfiles"
stow -d "$HOME/dotfiles" -t "$HOME" --restow zsh bash git
exec zsh
```

---

## 说明

- 这个仓库是给自己用的 dotfiles，不会把本机密钥提交进 Git。
- `*.local` 文件会被 `.gitignore` 忽略。
- 修改配置后，直接在 `$HOME` 下编辑对应文件即可，仓库里的文件会同步更新。
