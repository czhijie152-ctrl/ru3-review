# 线上版部署说明（GitHub Pages）

## 网站地址

**https://czhijie152-ctrl.github.io/ru3-review/**

手机、平板、异地电脑都能直接打开，免费 HTTPS，不需要登录。

## 这个目录是什么

| 文件 | 说明 |
|---|---|
| `index.html` | 线上页面本体（由 `..\俄语复习.html` 复制而来，**不要直接改**） |
| `publish.ps1` | 一键更新脚本：重新构建 → 复制 → 提交 → 推送 → 等 Pages 构建完 |
| `.nojekyll` | 让 GitHub Pages 跳过 Jekyll 处理，按原样发布 |
| `.gitattributes` | 禁止换行符转换，保证线上文件与本地**字节一致** |

## 以后改内容怎么更新

1. 改 `..\data\lessonNN.json`（或 `..\build.py` 里的界面/逻辑）
2. 在 PowerShell 里跑：

```powershell
E:\deepseek\大学俄语\复习工具\deploy\publish.ps1
```

脚本最后会打印网站地址，并确认线上大小已经和本地一致。一般 30–60 秒生效。

## 如果推送报连接错误

这台机器访问 github.com 需要走本地代理（Clash 类工具，端口 `7897`）。已经给 git 配好了：

```powershell
git config --global http.proxy  http://127.0.0.1:7897
git config --global https.proxy http://127.0.0.1:7897
git config --global http.sslBackend schannel
```

如果哪天代理端口变了（换工具/改配置），把上面的 `7897` 换成新端口即可。想取消代理：

```powershell
git config --global --unset http.proxy
git config --global --unset https.proxy
```

## 仓库信息

| 项 | 值 |
|---|---|
| 仓库 | https://github.com/czhijie152-ctrl/ru3-review （Public） |
| 分支 | `main`，Pages 从根目录 `/` 发布 |
| 部署方式 | legacy（直接发布静态文件，无构建步骤） |

## 安全与隐私

- 网址不会出现在搜索引擎或 GitHub 目录里，但**任何拿到网址的人都能打开**（公开静态站，没有登录）。
- 学习进度（认识/不认识的词、错词本）存在**每个人自己的浏览器**里（localStorage，按域名隔离），不会上传到 GitHub。
- 部署时用过的 GitHub Token 只勾了 `repo` 权限，作用仅限于推送内容。**建议用完就去
  https://github.com/settings/tokens 把它 Delete 掉**——删掉后网站照常运行，只是下次更新需要新建一个 Token 再 `git push`。
