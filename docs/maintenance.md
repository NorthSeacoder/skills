# 维护规范

## 日常流程

对任意受管 skill，固定按下面顺序处理：

1. 在 `skills/<name>/` 下编辑源码
2. 如元数据有变化，更新 `registry/skills.yaml`
3. 运行 `bash scripts/verify-skills.sh`
4. 运行 `bash scripts/publish-links.sh`

## 定期审核

周期性检查每个受管 skill：

- 是否还在用
- 是否仍兼容当前工具链
- 是否已被更好的方案替代
- 注册表元数据是否仍准确

## 废弃策略

如果某个 skill 不再值得维护：

- 在 registry 中设置 `status: deprecated`
- 从运行时目录取消发布
- 如果保留源码仍有参考价值，可以继续留在仓库

## adopted skill 升级

不要自动追踪上游 HEAD。

如果要升级 adopted skill：

- 记录上游仓库、路径和版本或提交
- 记录本地改动点
- 重新确认当前运行环境假设仍成立

## 运行时安全

发布脚本绝不能覆盖：

- 不属于本仓库管理的真实目录
- 指向其他位置的软链接

出现冲突时，应显式处理，不要绕过。
