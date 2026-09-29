# dotfiles

## English Version

A personal shell configuration set for macOS and Debian/Ubuntu that uses stow to link `zsh`, `bash`, and `git` configurations to `$HOME`.

The most basic installation method is at the top:

```bash
git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

If SSH is not configured yet, use HTTPS:

```bash
git clone https://github.com/RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

---

### Files and Directories

```text
dotfiles/
├── bootstrap.sh       # New machine initialization script
├── zsh/
│   └── .zshrc         # Zsh configuration
├── bash/
│   └── .bashrc        # Bash configuration
├── git/
│   ├── .gitconfig     # Git configuration
│   └── .gitignore_global # Global Git ignore rules
└── .gitignore         # Repository's own ignore rules
```

#### `bootstrap.sh`

One-click initialization script for new machines, mainly responsible for "installing and preparing the environment":

- Install tools using Homebrew or `apt` depending on the system
- Install Zsh, Git, Stow, fzf, zoxide, eza, bat, fd, gh, etc.
- Install Oh My Zsh and Zsh plugins
- Install Claude Code
- Use Stow to link configuration files to `$HOME`
- Create `~/.zshrc.local` for machine-specific configuration

It typically only needs to run once on a new machine, but can be re-executed when updating configurations.

#### `zsh/`

Stores Zsh configuration. `zsh/.zshrc` is loaded when Zsh starts and is used to set:

- Oh My Zsh and plugins
- aliases
- Completions for `fzf`, `zoxide`, `nvm`, and GitHub CLI
- Machine-specific `~/.zshrc.local`

It handles "environment configuration at startup" but does not install software.

#### `bash/`

Stores Bash configuration. `bash/.bashrc` handles Bash startup settings:

- Aliases and command completion
- Configuration for `fzf`, `nvm`, and `zoxide`
- Machine-specific `~/.bashrc.local`

#### `git/`

Stores Git-related configuration:

- `.gitconfig`: Git username, email, and global ignore file location
- `.gitignore_global`: Ignore rules common to all Git repositories

#### `.gitignore`

Only used to ignore files in the current dotfiles repository, such as logs, `.DS_Store`, and `*.local` files, to avoid committing machine-specific or sensitive information to Git.

---

### Configuration File Symlink Relationships

After running `bootstrap.sh`, Stow will link configurations from the repository to the user's home directory:

```text
~/.zshrc            -> ~/dotfiles/zsh/.zshrc
~/.bashrc           -> ~/dotfiles/bash/.bashrc
~/.gitconfig        -> ~/dotfiles/git/.gitconfig
~/.gitignore_global -> ~/dotfiles/git/.gitignore_global
```

Therefore, the shell actually loads files from `$HOME`, but the file contents are managed centrally by the `~/dotfiles` repository. Since these files are symlinks, using commands like `cat ~/.zshrc` or `cat ~/.bashrc` will show the linked files.

Editing `~/.zshrc` or `~/.bashrc` will also modify `~/dotfiles/zsh/.zshrc` or `~/dotfiles/bash/.bashrc`. If you only want to save machine-specific configuration (such as API keys, proxies, or local aliases), please use the `.local` files.

Note: `~/.zshrc` automatically loads `~/.zshrc.local`, and `~/.bashrc` automatically loads `~/.bashrc.local`. Therefore, place machine-specific private configuration in these two `.local` files, and there is no need to manually add them.

Check if symlinks are working:

```bash
ls -l ~/.zshrc ~/.bashrc ~/.gitconfig ~/.gitignore_global
```

---

### Supported Systems

- macOS
- Debian / Ubuntu

### What `bootstrap.sh` Automatically Does

- Install common tools: `zsh`, `git`, `stow`, `fzf`, `zoxide`, `eza`, `bat`, `fd`, `gh`
- Install Oh My Zsh and plugins
- Install Claude Code
- Link configurations to `$HOME` using `stow`
- Create `~/.zshrc.local` for machine-specific private configuration that won't be committed to the repository

### macOS Detailed Steps

```bash
# 1. Install developer tools (if not already installed)
xcode-select --install

# 2. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install dotfiles
git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

### Debian / Ubuntu Detailed Steps

```bash
sudo apt-get update
sudo apt-get install -y git curl ca-certificates sudo

git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

If the current shell is not zsh:

```bash
chsh -s "$(command -v zsh)"
```

### GitHub SSH Login (if using SSH clone)

```bash
ssh-keygen -t ed25519 -C "shaorunxinnb@gmail.com"
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"
cat "$HOME/.ssh/id_ed25519.pub"
```

Copy the output public key to GitHub:

- GitHub → Settings → SSH and GPG keys → New SSH key

Then test:

```bash
ssh -T git@github.com
```

### Machine-Specific Configuration

Keep public configuration in the repository and machine-specific content in the following files:

```bash
~/.zshrc.local
~/.bashrc.local
```

`bootstrap.sh` will automatically create `~/.zshrc.local`. Edit machine-specific Zsh configuration:

```bash
${EDITOR:-vi} "$HOME/.zshrc.local"
```

Example:

```bash
# export ANTHROPIC_API_KEY="..."
# export HTTP_PROXY="http://127.0.0.1:7890"
# alias cproj='cd ~/projects/myproject'
```

Do not put API keys, passwords, tokens, or private keys into configuration files in the repository. `*.local` files will be ignored by `.gitignore`.

### Updating Configuration

```bash
cd "$HOME/dotfiles"
git pull --ff-only
bash ./bootstrap.sh
exec zsh
```

If you only want to sync stow links:

```bash
cd "$HOME/dotfiles"
stow -d "$HOME/dotfiles" -t "$HOME" --restow zsh bash git
```

### FAQ

#### 1. `git clone` reports Permission denied (publickey)

This means SSH key is not configured properly. Use HTTPS instead or configure SSH first.

#### 2. Current terminal shell hasn't switched to zsh

```bash
exec zsh
```

#### 3. `claude` command not found

```bash
exec zsh
command -v claude
```

#### 4. `zsh` configuration not taking effect

```bash
cd "$HOME/dotfiles"
stow -d "$HOME/dotfiles" -t "$HOME" --restow zsh bash git
exec zsh
```

---

### Notes

- This repository is for personal use. Machine-specific keys will not be committed to Git.
- `*.local` files will be ignored by `.gitignore`.
- After modifying configuration, directly edit the corresponding file in `$HOME`, and files in the repository will be synchronized automatically.

---

## 中文版本

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

新机器上的一键初始化脚本，主要负责"安装和准备环境"：

- 根据系统使用 Homebrew 或 `apt` 安装工具
- 安装 Zsh、Git、Stow、fzf、zoxide、eza、bat、fd、gh 等
- 安装 Oh My Zsh 和 Zsh 插件
- 安装 Claude Code
- 使用 Stow 把配置文件链接到 `$HOME`
- 创建 `~/.zshrc.local`，保存本机专属配置

它通��只需要在新机器上执行一次；以后更新配置时也可以重新执行。

### `zsh/`

存放 Zsh 配置。`zsh/.zshrc` 会在启动 Zsh 时加载，用来设置：

- Oh My Zsh 和插件
- alias
- `fzf`、`zoxide`、`nvm`、GitHub CLI 补全
- 本机的 `~/.zshrc.local`

它负责"启动时配置环境"，不负责安装软件。

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

因此，Shell 实际加载的是 `$HOME` 下的文件，但文件内容由 `~/dotfiles` 仓库统一管理。由于这些文件是软链接，使用 `cat ~/.zshrc`、`cat ~/.bashrc` 等命令查看得到的是链接指向的文件。

修改 `~/.zshrc` 或 `~/.bashrc`，实际也会修改 `~/dotfiles/zsh/.zshrc` 或 `~/dotfiles/bash/.bashrc`。如果只想保存本机专属的配置（例如 API key、代理或本机 alias），请使用 `.local` 文件。

注意：`~/.zshrc` 会自动加载 `~/.zshrc.local`，`~/.bashrc` 也会自动加载 `~/.bashrc.local`。因此，把本机私密配置放在这两个 `.local` 文件里即可，不需要手动写进去。

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

公共配置放在仓库中，本机专属内容放在以下文件中：

```bash
~/.zshrc.local
~/.bashrc.local
```

`bootstrap.sh` 会自动创建 `~/.zshrc.local`。编辑 Zsh 的本机配置：

```bash
${EDITOR:-vi} "$HOME/.zshrc.local"
```

示例：

```bash
# export ANTHROPIC_API_KEY="..."
# export HTTP_PROXY="http://127.0.0.1:7890"
# alias cproj='cd ~/projects/myproject'
```

不要把 API key、密码、token 或私钥写入仓库中的配置文件。`*.local` 文件会被 `.gitignore` 忽略。

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
