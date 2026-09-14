#!/usr/bin/env bash
set -euo pipefail

entry_dir="$(cd "$(dirname "$0")/.." && pwd)"
launcher="${entry_dir}/kaiwu"

bash -n "$launcher"
[[ -x "$launcher" ]] || { echo "统一入口脚本不可执行。" >&2; exit 1; }

for required in README.md CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md LICENSE \
    docs/REPOSITORIES.md kaiwu-entry.env; do
  [[ -f "${entry_dir}/${required}" ]] || { echo "缺少 ${required}" >&2; exit 1; }
done

output="$(KAIWU_REPOSITORY_BASE_URL='https://github.com/example' \
  KAIWU_REPOSITORY_REF='v1.2.3' "$launcher" repositories)"
printf '%s\n' "$output" | grep -Fq 'https://github.com/example/kaiwu-system-service.git'
printf '%s\n' "$output" | grep -Fq '全部产品仓固定使用 v1.2.3'

for command_name in doctor repositories init up dev deploy-init context-public-key import-project-menu; do
  "$launcher" help | grep -Fq "$command_name"
done

if KAIWU_REPOSITORY_BASE_URL='file:///tmp/not-allowed' "$launcher" repositories \
    >/dev/null 2>&1; then
  echo "入口不应接受本地 file URL。" >&2
  exit 1
fi
if "$launcher" up unexpected >/dev/null 2>&1; then
  echo "入口不应忽略多余参数。" >&2
  exit 1
fi

temp_workspace="$(mktemp -d "${TMPDIR:-/tmp}/kaiwu-entry-check.XXXXXX")"
trap 'rm -rf "$temp_workspace"' EXIT
mkdir -p "${temp_workspace}/kaiwu-system-service/.git" \
  "${temp_workspace}/kaiwu-system-service/scripts"
# shellcheck disable=SC2016 # 测试夹具需要把变量表达式原样写入伪 System 启动器。
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "%s|%s|%s\\n" "$KAIWU_REPOSITORY_BASE_URL" "$KAIWU_REPOSITORY_REF" "$*"' \
  > "${temp_workspace}/kaiwu-system-service/scripts/kaiwu.sh"
chmod +x "${temp_workspace}/kaiwu-system-service/scripts/kaiwu.sh"

delegated_output="$(KAIWU_WORKSPACE_DIR="$temp_workspace" \
  KAIWU_REPOSITORY_BASE_URL='https://github.com/example' \
  KAIWU_REPOSITORY_REF='v1.2.3' "$launcher" status)"
[[ "$delegated_output" == 'https://github.com/example|v1.2.3|status' ]] || {
  echo "入口没有按预期把仓库来源、版本和命令委托给 System。" >&2
  exit 1
}

# 组织内地址守卫。
#
# 曾经逐个列举主机名，域名一换就全部失配，检查有很长一段时间每次都"通过"、实际一条
# 都没拦住。现在默认只匹配任何组织都适用的信号：.internal 后缀与 RFC1918 私网地址。
#
# 自己的组织名/域名用 KAIWU_INTERNAL_PATTERN 追加（ERE，用 | 分隔），例如：
#   KAIWU_INTERNAL_PATTERN='acme|acme\.internal' bash scripts/check.sh
# 本文件不硬编码任何组织的名字——它自己也是要公开的。
internal_pattern='\.internal\b|(^|[^0-9.])(10\.[0-9]{1,3}|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\.[0-9]{1,3}\.[0-9]{1,3}'
if [[ -n "${KAIWU_INTERNAL_PATTERN:-}" ]]; then
  internal_pattern="${KAIWU_INTERNAL_PATTERN}|${internal_pattern}"
fi
# 文档里的占位地址（example.internal / example.com 等）是我们希望读者照抄的写法，
# 不能被当成泄露。kaiwu-system-service 的同款守卫就是在这里误伤了 README 里的
# nacos.example.internal，整条流水线因此红掉。
hits=$(grep -RInE --binary-files=without-match "$internal_pattern" \
    "$entry_dir" --exclude-dir=workspace --exclude-dir=.git \
    --exclude="$(basename "${BASH_SOURCE[0]}")" \
    | grep -vE 'example\.(internal|com|org|net|invalid)|\.example\.' || true)
if [[ -n "$hits" ]]; then
  printf '%s\n' "$hits" >&2
  echo "开源入口中发现组织内地址或私网地址。" >&2
  exit 1
fi

echo "Kaiwu 开源统一入口检查通过。"
