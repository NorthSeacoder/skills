# Data Model: [功能名称]

**Workspace**: `[工作区名称]` | **Date**: [日期]

> 仅在 `plan` 阶段确认存在实体、状态、关系或存储变化，且无法在 `plan.md` 中简洁表达时创建此文件。

---

## Entities

### [实体名] (表名: `t_xxx`)

**描述**: [实体职责描述]

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | Long | PK, AUTO_INCREMENT | 主键 |
| xxx_id | Long | NOT NULL, INDEX | 关联ID |
| name | String(64) | NOT NULL | 名称 |
| status | Integer | NOT NULL, DEFAULT 0 | 状态：0-初始, 1-处理中, 2-成功, 3-失败 |
| created_at | DateTime | NOT NULL | 创建时间 |
| updated_at | DateTime | NOT NULL | 更新时间 |

**索引**:
- `idx_xxx_id` on (xxx_id)
- `idx_created_at` on (created_at)

**状态转换** (如适用):

```text
INIT(0) → PROCESSING(1) → SUCCESS(2)
                       ↘ FAILED(3)
```

---

## Relationships

```text
[实体A] 1:N [实体B]
[实体B] N:1 [实体C]
```

---

## DDL Scripts

```sql
-- [实体名]
CREATE TABLE `t_xxx` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `xxx_id` BIGINT NOT NULL,
    `name` VARCHAR(64) NOT NULL,
    `status` INT NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## Migration Notes

- Flyway 版本号: `V[版本]__[描述].sql`
- 回滚策略: [描述]
