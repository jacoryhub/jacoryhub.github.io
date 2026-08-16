# 个人 roothide 越狱源

这是一个可直接部署到 GitHub Pages 的个人 APT 源模板，适合 Sileo、Zebra 等支持 Debian 仓库格式的包管理器。

## 快速部署

1. 当前仓库为 [`jacoryhub/roothide-repo`](https://github.com/jacoryhub/roothide-repo)，源码位于 `main` 分支。
2. 在仓库 **Settings → Pages → Build and deployment** 中选择 **GitHub Actions**。
3. 等待 `Build and deploy repository` 工作流完成。仓库地址通常是：
   `https://jacoryhub.github.io/roothide-repo/`
4. 在 Sileo/Zebra 中添加这个地址。首页会根据实际访问地址显示可复制的源 URL。

本地初始化示例：

```sh
cd "/Users/jacory/Documents/自建越狱源"
git init -b main
git add .
git commit -m "Initialize roothide APT repository"
git remote add origin git@github.com:jacoryhub/roothide-repo.git
git push -u origin main
```

## 发布软件包

将 `.deb` 放入 `debs/` 后提交推送即可：

```sh
cp path/to/PACKAGE.deb debs/
git add debs/PACKAGE.deb
git commit -m "Add PACKAGE"
git push
```

目录中若有现成的 `插件备份/`，可以直接导入（脚本只复制，不会删除原文件）：

```sh
./scripts/import-backups.sh
```

导入前请确认每个包的来源、许可证和公开分发条件；包一旦推送到 GitHub，文件就是公开下载内容。

Actions 会生成 `Packages`、`Packages.gz`、`Packages.bz2` 和 `Release`。索引中的 `Filename` 会使用 `debs/<文件名>.deb`，因此不要在发布后移动或重命名包文件。

当前导入的备份保留了原始中文/空格文件名；若某个客户端下载失败，将对应文件改成只含 ASCII 的名称后重新提交即可。

## roothide 兼容性检查

- 你现有的 Relaxin 包声明为 `Architecture: iphoneos-arm64e`，仓库会从 `Packages` 自动读取架构；新包应与该值及 rootless/roothide 目录布局保持一致。
- 检查包的 `Depends`、最低 iOS 版本、注入器（例如 ElleKit）和是否依赖特定 bootstrap；这些信息应写入包控制文件和发布说明。
- 不要把个人证书、设备备份、私有密钥或未确认来源的二进制提交到仓库。`.deb` 本身会被公开下载。
- GitHub 单文件和仓库大小有限制；大型包可放在 GitHub Release，再在仓库中保留适配后的发布包和说明。

## 本地构建与验证

macOS 默认没有 `dpkg-scanpackages`。安装 Debian 工具后执行：

```sh
# Debian/Ubuntu
sudo apt-get install dpkg-dev
./scripts/build-repo.sh
./scripts/validate-repo.sh
```

没有包时索引仍可生成，但 Sileo 中不会显示任何条目；将第一个 `.deb` 推送后再检查工作流日志和源页面。
