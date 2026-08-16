# jacory 越狱源项目上下文

> 这份文档供后续 GPT/Codex 新会话读取。先读本文件，再检查 `git status`，不要重复初始化仓库或覆盖已有插件。

## 1. 项目定位

- 项目：个人 iOS APT 软件源，服务 Sileo、Zebra 等 Debian 仓库客户端。
- 设备环境：iPhone 14 Pro Max，iOS 17.0。
- 越狱环境：Relaxin 隐根（roothide），软件包架构主要为 `iphoneos-arm64e`。
- 源名称：`jacory`。
- 本地目录：`/Users/jacory/Documents/自建越狱源`。

## 2. 远端信息

- GitHub 仓库：<https://github.com/jacoryhub/jacoryhub.github.io>
- GitHub Pages 源地址：<https://jacoryhub.github.io/>
- Git 分支：`main`。
- Git 远程：`git@github.com:jacoryhub/jacoryhub.github.io.git`（SSH）。
- Sileo 添加地址：`https://jacoryhub.github.io/`。
- Pages 部署方式：`.github/workflows/pages.yml` 中的 GitHub Actions。

## 3. 当前状态

- 最近一次图标/兼容性提交：`fa4c49a Use PNG source icons for Sileo`。
- 最近一次插件更新提交：`8df5797 Update repository packages`。
- 当前工作树在整理本文档前是干净的。
- 最近部署索引包含 41 个软件包，架构为 `iphoneos-arm64e`。
- GitHub Actions 会在每次推送到 `main` 后自动生成并部署 APT 索引。

## 4. 重要文件

| 文件 | 用途 |
| --- | --- |
| `repo.json` | 源名称、描述、网站、维护者和源图标 URL。当前图标指向 `https://jacoryhub.github.io/assets/icon.png?v=6`。 |
| `assets/icon.svg` | 网页使用的矢量版赛博机器人图标。 |
| `assets/icon.png` | Sileo 使用的 512×512 PNG 图标；PNG 是当前兼容性关键。 |
| `CydiaIcon.png` | 根目录兼容入口，和 `assets/icon.png` 内容相同。 |
| `index.html` | GitHub Pages 首页，展示源名称、软件包数量和添加源信息。 |
| `debs/` | 实际公开发布的 `.deb` 文件目录。 |
| `插件备份/` | 本地插件备份目录，已在 `.gitignore` 中忽略，不会直接发布。 |
| `scripts/build-repo.sh` | 使用 `dpkg-scanpackages` 生成 `Packages`、压缩索引和 `Release`。 |
| `scripts/validate-repo.sh` | 检查索引压缩完整性、包路径和每个包的 `Filename`。 |
| `scripts/import-backups.sh` | 将 `插件备份/` 中的包复制到 `debs/`，不会删除现有文件。 |
| `.github/workflows/pages.yml` | 安装 `dpkg-dev`、构建/验证索引并部署 Pages。 |
| `Makefile` | `make build`、`make validate` 和清理本地生成索引。 |

## 5. 图标问题的最终解决方案

Sileo 对原来的 SVG 源图标没有采用，源列表显示默认灰色占位图。当前方案是：

1. 保留 `assets/icon.svg` 给网页使用。
2. 使用同一视觉设计导出 `assets/icon.png`，尺寸 512×512，类型 `image/png`。
3. `repo.json` 的 `icon` 字段指向 PNG，并通过 `?v=6` 更新缓存版本。
4. 根目录额外提供 `CydiaIcon.png`，兼容使用该文件名的客户端。

当前视觉要求：硬朗赛博机器人、科技感、半透明蓝灰镜片、保留香烟和烟雾；不要可爱风，也不要纯黑镜片遮挡脸部。

## 6. 发布或替换插件

### 新增插件

把 `.deb` 放到 `debs/`，然后执行：

```sh
cd "/Users/jacory/Documents/自建越狱源"
git add debs/NEW_PACKAGE.deb
git commit -m "Add NEW_PACKAGE"
git push origin main
```

### 替换插件

如果替换文件的文件名相同，直接覆盖后提交。如果文件名变化，必须同时删除旧路径并添加新路径：

```sh
git add -A debs
git diff --cached --name-status
git commit -m "Update repository packages"
git push origin main
```

GitHub Actions 成功后，Sileo 下拉刷新源即可看到新版本。软件包的 Debian `Package`、`Version`、`Architecture` 等字段来自 `.deb` 内部控制信息，不是文件名。

### 导入备份

```sh
./scripts/import-backups.sh
git add debs
git commit -m "Import repository packages"
git push origin main
```

## 7. 构建与验证

macOS 默认没有 `dpkg-scanpackages`。本地有 Debian 工具时可以运行：

```sh
./scripts/build-repo.sh
./scripts/validate-repo.sh
```

Debian/Ubuntu 安装工具：

```sh
sudo apt-get update
sudo apt-get install -y dpkg-dev
```

本项目通常直接推送，让 Actions 在 Ubuntu 中构建。可检查最近工作流：

```sh
curl -sS 'https://api.github.com/repos/jacoryhub/jacoryhub.github.io/actions/runs?per_page=3' \
  | jq -r '.workflow_runs[] | [.id,.status,.conclusion,.head_sha] | @tsv'
```

检查远端源元数据和图标：

```sh
curl -L 'https://jacoryhub.github.io/repo.json?check=1'
curl -I 'https://jacoryhub.github.io/assets/icon.png?v=6'
curl -L 'https://jacoryhub.github.io/Packages?refresh=1' | rg '^(Package|Version|Architecture|Filename):'
```

## 8. 注意事项

- 不要把个人证书、设备备份、私钥或不确定来源的文件推送到公开仓库。
- `.deb` 一旦进入 `main` 并部署到 Pages，就是公开可下载文件。
- `Packages`、`Packages.gz`、`Packages.bz2`、`Release` 是 CI 生成文件，已被 `.gitignore` 忽略，不需要手工提交。
- `debs/` 中已有中文和空格文件名；如果某个客户端下载失败，再单独将该包改成 ASCII 文件名并同步更新索引。
- 替换插件前先执行 `git status --short`，保留用户已有改动，不使用破坏性 Git 命令。
- 新会话开始时先读本文件，再读取 `README.md`、`repo.json` 和 `.github/workflows/pages.yml`。

