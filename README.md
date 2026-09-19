# dotfiles

这是一套适用于 **macOS** 和 **Debian/Ubuntu Linux** 的个人 Shell 配置，使用 [GNU Stow](https://www.gnu.org/software/stow/) 将配置文件链接到 `$HOME`。

目前包含：

- `zsh/.zshrc`：Zsh、Oh My Zsh、常用 alias、fzf、zoxide、GitHub CLI 补全等
- `bash/.bashrc`：Bash、常用 alias、fzf、zoxide 等
- `git/.gitconfig`：Git 用户信息和全局 `.gitignore`
- `bootstrap.sh`：新机器/新虚拟机的一键安装和配置脚本

> **最常用的做法：** 新机器安装好 Git 后，clone 仓库并执行 `bootstrap.sh`，脚本会自动安装工具、Oh My Zsh、插件并创建 Stow 软链接。

---

## 目录

- [适用系统和安装内容](#适用系统和安装内容)
- [新机器快速安装](#新机器快速安装)
- [macOS 详细步骤](#macos-详细步骤)
- [DebianUbuntu 详细步骤](#debianubuntu-详细步骤)
- [GitHub SSH 登录](#github-ssh-登录)
- [安装完成后的检查](#安装完成后的检查)
- [本机专属配置和密钥](#本机专属配置和密钥)
- [日常更新 dotfiles](#日常更新-dotfiles)
- [修改配置并同步到仓库](#修改配置并同步到仓库)
- [常见问题](#常见问题)
- [手动恢复或卸载](#手动恢复或卸载)

## 适用系统和安装内容

### 支持的平台

- macOS（Intel 和 Apple Silicon）
- 使用 `apt-get` 的 Debian/Ubuntu Linux

其他 Linux 发行版也可以使用仓库中的配置文件，但 `bootstrap.sh` 不会自动安装依赖，需要先手动安装对应工具。

### `bootstrap.sh` 会做什么

脚本可以重复执行，已存在的内容通常会自动跳过或重新建立链接。主要步骤如下：

1. 在 macOS 上使用 Homebrew 安装，在 Debian/Ubuntu 上使用 `apt-get` 安装：
   - `zsh`
   - `git`
   - `curl`、`wget`、`ca-certificates`
   - `stow`
   - `eza`、`bat`、`fd`
   - `fzf`
   - `zoxide`
   - `gh`（GitHub CLI）
2. 安装 Oh My Zsh。
3. 安装：
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
4. 安装 Claude Code。
5. 使用 Stow 将 `zsh`、`bash`、`git` 目录中的配置链接到 `$HOME`。
6. 创建 `~/.zshrc.local` 模板，用于保存当前机器的密钥、代理和私有 alias。

脚本**不会**把 `~/.zshrc.local`、`~/.bashrc.local` 或密钥提交到仓库。

---

## 新机器快速安装

下面的命令适用于已经可以使用 `git` 的机器。

### 1. 使用 SSH clone（推荐）

```bash
git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
```

### 2. 如果还没有配置 GitHub SSH，使用 HTTPS clone

```bash
git clone https://github.com/RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
```

### 3. 让配置立即生效

```bash
exec zsh
```

也可以关闭当前终端，再打开一个新的终端窗口。

如果登录 Shell 还不是 Zsh，Linux 上执行：

```bash
chsh -s "$(command -v zsh)"
```

然后注销并重新登录，或者重启终端。

---

## macOS 详细步骤

### 1. 打开 Terminal

macOS 默认通常已经有 Git。如果没有，先执行：

```bash
git --version
```

按照系统提示安装 Xcode Command Line Tools：

```bash
xcode-select --install
```

安装完成后再次确认：

```bash
git --version
```

### 2. 安装 Homebrew

检查 Homebrew 是否已经存在：

```bash
brew --version
```

如果提示找不到命令，执行官方安装脚本：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装结束后，按照终端输出把 Homebrew 加入当前用户的 `PATH`。常见配置如下。

Apple Silicon Mac：

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Intel Mac：

```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
eval "$(/usr/local/bin/brew shellenv)"
```

确认：

```bash
brew --version
```

### 3. 下载并执行 dotfiles

```bash
git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

脚本会自动使用 Homebrew 安装所需工具，并处理 Intel/Apple Silicon 的 Homebrew 路径。

---

## Debian/Ubuntu 详细步骤

### 1. 更新系统并安装最小依赖

如果系统尚未安装 Git、curl 和 sudo，可以先执行：

```bash
sudo apt-get update
sudo apt-get install -y git curl sudo ca-certificates
```

确认：

```bash
git --version
curl --version
```

### 2. 下载并执行 dotfiles

```bash
git clone git@github.com:RunxinShao/dotfiles.git "$HOME/dotfiles"
bash "$HOME/dotfiles/bootstrap.sh"
exec zsh
```

脚本会执行 `apt-get update`，并自动安装 Zsh、Stow、fzf、zoxide、eza、bat、fd 和 GitHub CLI 等工具。

### 3. 设置默认 Shell

如果脚本最后提示当前登录 Shell 不是 Zsh，执行：

```bash
chsh -s "$(command -v zsh)"
```

查看当前默认 Shell：

```bash
echo "$SHELL"
```

设置后需要注销并重新登录。只想当前终端立即使用 Zsh，可以执行：

```bash
exec zsh
```

---

## GitHub SSH 登录

如果使用 SSH clone，需要先在新机器生成 SSH key，并将公钥添加到 GitHub。

### 1. 生成 SSH key

```bash
ssh-keygen -t ed25519 -C "shaorunxinnb@gmail.com"
```

一路按回车可以使用默认路径；建议为 key 设置密码。

### 2. 启动 ssh-agent 并添加 key

```bash
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"
```

### 3. 查看并复制公钥

```bash
cat "$HOME/.ssh/id_ed25519.pub"
```

复制完整输出，然后在 GitHub 中进入：

**Settings → SSH and GPG keys → New SSH key**

粘贴公钥并保存。

### 4. 测试连接

```bash
ssh -T git@github.com
```

第一次连接会询问是否信任 GitHub 的 host key，确认指纹无误后输入 `yes`。连接成功后重新执行 SSH clone 命令即可。

> 私钥 `~/.ssh/id_ed25519` 绝对不要提交到这个仓库；只添加 `.pub` 公钥到 GitHub。

---

## 安装完成后的检查

### 检查软链接

```bash
ls -l "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.gitconfig" "$HOME/.gitignore_global"
```

这些文件应该链接到 `~/dotfiles` 下对应的文件。

也可以使用：

```bash
readlink "$HOME/.zshrc"
readlink "$HOME/.gitconfig"
```

### 检查工具

```bash
zsh --version
git --version
gh --version
stow --version
eza --version
fzf --version
zoxide --version
```

### 检查 Git 配置

```bash
git config --global --list
git config --global user.name
git config --global user.email
```

当前仓库中的 Git 身份是：

```text
user.name  = runxin shao
user.email = shaorunxinnb@gmail.com
```

### 登录 GitHub CLI

如果需要使用 `gh`，执行：

```bash
gh auth login
```

推荐选择：

1. `GitHub.com`
2. `HTTPS` 或 `SSH`（按自己的 Git 使用方式选择）
3. 使用浏览器登录，或使用 token 登录

检查登录状态：

```bash
gh auth status
```

### 测试常用功能

```bash
# 查看目录
eza -la

# 查看 Git 分支和状态
git status

# zoxide 初始化后可以使用 z 跳转目录
z dotfiles

# fzf 默认快捷键：Ctrl+R、Ctrl+T、Alt+C
```

---

## 本机专属配置和密钥

公共配置放在仓库中；只属于某一台机器的内容放在本机文件中。

### Zsh

脚本会自动创建：

```bash
~/.zshrc.local
```

编辑它：

```bash
${EDITOR:-vi} "$HOME/.zshrc.local"
```

示例：

```zsh
# 不要把真实密钥提交到 GitHub
# export ANTHROPIC_API_KEY="your-key"

# 公司代理或本机专用 alias 也可以放这里
# export HTTP_PROXY="http://127.0.0.1:7890"
# alias cproj='cd ~/projects/my-private-project'
```

保存后执行：

```bash
source "$HOME/.zshrc.local"
```

或者重新加载完整 Shell：

```bash
exec zsh
```

### Bash

Bash 的本机专属配置可以放在：

```bash
~/.bashrc.local
```

创建并编辑：

```bash
touch "$HOME/.bashrc.local"
chmod 600 "$HOME/.bashrc.local"
${EDITOR:-vi} "$HOME/.bashrc.local"
```

### 安全注意事项

- 不要把 API key、密码、token、私钥写入仓库中的 `.zshrc`、`.bashrc` 或其他文件。
- 不要执行 `git add -f` 强行添加本机密钥文件。
- 仓库的 `.gitignore` 已忽略 `*.local`，但提交前仍应检查：

```bash
git status
 git diff --cached
```

---

## 日常更新 dotfiles

在已有机器上拉取最新配置：

```bash
cd "$HOME/dotfiles"
git pull --ff-only
bash ./bootstrap.sh
exec zsh
```

如果只想更新配置软链接，不想重新执行安装步骤：

```bash
cd "$HOME/dotfiles"
stow -d "$HOME/dotfiles" -t "$HOME" --restow zsh bash git
```

> 如果 `git pull` 报本地修改冲突，请先检查本地修改，不要直接覆盖：
>
> ```bash
> git status
> git diff
> ```

---

## 修改配置并同步到仓库

由于 `$HOME/.zshrc`、`$HOME/.bashrc` 和 `$HOME/.gitconfig` 是软链接，直接编辑 `$HOME` 下的文件就会修改仓库中的文件。

例如编辑 Zsh 配置：

```bash
${EDITOR:-vi} "$HOME/.zshrc"
```

检查修改：

```bash
cd "$HOME/dotfiles"
git diff
```

测试配置是否有语法错误：

```bash
zsh -n zsh/.zshrc
bash -n bash/.bashrc
```

确认无误后提交并推送：

```bash
cd "$HOME/dotfiles"
git add zsh/.zshrc bash/.bashrc git/.gitconfig git/.gitignore_global
 git commit -m "Update shell configuration"
git push origin main
```

推送前建议检查是否误加入敏感内容：

```bash
git diff --cached --check
git status
```

修改后让当前 Shell 生效：

```bash
exec zsh
```

或者如果当前使用 Bash：

```bash
source "$HOME/.bashrc"
```

---

## 常见问题

### 1. `git clone` 报 Permission denied (publickey)

说明 GitHub SSH key 没有配置好。可以：

- 按照 [GitHub SSH 登录](#github-ssh-登录) 生成并添加 key；或
- 暂时改用 HTTPS：

```bash
git clone https://github.com/RunxinShao/dotfiles.git "$HOME/dotfiles"
```

### 2. Stow 报文件冲突

如果 `$HOME/.zshrc` 等文件已经存在且不是本仓库创建的软链接，Stow 可能拒绝覆盖。先备份：

```bash
mkdir -p "$HOME/dotfiles-backup"
for f in .zshrc .bashrc .gitconfig .gitignore_global; do
  [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ] && cp -p "$HOME/$f" "$HOME/dotfiles-backup/$f"
done
```

确认备份无误后，再执行：

```bash
bash "$HOME/dotfiles/bootstrap.sh"
```

### 3. `sudo` 不存在或没有 sudo 权限

`bootstrap.sh` 在 Linux 上需要用系统包管理器安装依赖。请使用有 sudo 权限的用户，或让管理员先安装所需软件。

### 4. 当前终端找不到刚安装的 `claude`

重新加载 Shell：

```bash
exec zsh
```

然后检查：

```bash
command -v claude
claude --version
```

### 5. `eza` 的图标显示为方块

配置中使用了自动图标。终端字体不支持 Nerd Font 时可能显示方块或问号。可以：

- 给终端配置 Nerd Font；或
- 修改 `~/.zshrc` / `~/dotfiles/zsh/.zshrc`，去掉 `--icons=auto`。

### 6. 配置改了但没有生效

确认当前文件是软链接，并重新加载：

```bash
ls -l "$HOME/.zshrc"
exec zsh
```

如果不是软链接，重新执行：

```bash
cd "$HOME/dotfiles"
stow -d "$HOME/dotfiles" -t "$HOME" --restow zsh bash git
```

### 7. 新机器用户名不同会不会失效

配置文件使用 `$HOME`，不会写死原机器的用户目录，因此更换用户名通常不会影响。机器专属设置请放在 `~/.zshrc.local` 或 `~/.bashrc.local`。

---

## 手动恢复或卸载

### 解除 Stow 软链接

```bash
cd "$HOME/dotfiles"
stow -d "$HOME/dotfiles" -t "$HOME" --delete zsh bash git
```

这只会解除 Stow 创建的链接，不会卸载 Oh My Zsh、插件或系统软件。

### 删除仓库

确认不再需要后：

```bash
rm -rf "$HOME/dotfiles"
```

如果已经执行过 `stow --delete`，可以根据需要删除以下目录：

```bash
rm -rf "$HOME/.oh-my-zsh"
rm -rf "$HOME/.local/bin/claude"
```

删除前请先确认这些目录中没有其他程序或个人文件。

---

## 相关文件

- [bootstrap.sh](./bootstrap.sh)
- [zsh/.zshrc](./zsh/.zshrc)
- [bash/.bashrc](./bash/.bashrc)
- [git/.gitconfig](./git/.gitconfig)
- [git/.gitignore_global](./git/.gitignore_global)
