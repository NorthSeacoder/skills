#!/usr/bin/env python3
"""
Code Context Capture Script
自动捕获当前代码上下文信息（Git、项目、文件等）
用于 knowledge-management skill
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Dict, Optional, List


class CodeContextCapture:
    """代码上下文捕获器"""

    def __init__(self, cwd: Optional[str] = None):
        """
        初始化

        Args:
            cwd: 工作目录，默认为当前目录
        """
        self.cwd = Path(cwd) if cwd else Path.cwd()
        self.context = {}

    def run_git_command(self, args: List[str]) -> Optional[str]:
        """
        执行 Git 命令

        Args:
            args: Git 命令参数

        Returns:
            命令输出，失败返回 None
        """
        try:
            result = subprocess.run(
                ['git'] + args,
                cwd=self.cwd,
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                return result.stdout.strip()
            return None
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return None

    def get_git_info(self) -> Dict[str, Optional[str]]:
        """
        获取 Git 信息

        Returns:
            包含分支名和 commit hash 的字典
        """
        branch = self.run_git_command(['branch', '--show-current'])
        commit = self.run_git_command(['rev-parse', '--short', 'HEAD'])

        return {
            'branch': branch,
            'commit': commit,
            'in_git_repo': branch is not None or commit is not None
        }

    def get_project_name(self) -> str:
        """
        获取项目名称

        优先级：
        1. package.json 的 name 字段
        2. 项目根目录名

        Returns:
            项目名称
        """
        # 尝试从 package.json 获取
        package_json = self.cwd / 'package.json'
        if package_json.exists():
            try:
                with open(package_json, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    if 'name' in data:
                        return data['name']
            except (json.JSONDecodeError, IOError):
                pass

        # 使用目录名
        return self.cwd.name

    def get_git_root(self) -> Optional[Path]:
        """
        获取 Git 仓库根目录

        Returns:
            Git 根目录路径，如果不在 Git 仓库中返回 None
        """
        git_root = self.run_git_command(['rev-parse', '--show-toplevel'])
        if git_root:
            return Path(git_root)
        return None

    def capture(self) -> Dict:
        """
        捕获完整的代码上下文

        Returns:
            包含所有上下文信息的字典
        """
        # Git 信息
        git_info = self.get_git_info()

        # 项目信息
        project_name = self.get_project_name()

        # Git 根目录
        git_root = self.get_git_root()

        # 构建上下文
        context = {
            'project': project_name,
            'branch': git_info['branch'],
            'commit': git_info['commit'],
            'in_git_repo': git_info['in_git_repo'],
            'cwd': str(self.cwd),
        }

        # 如果在 Git 仓库中，添加相对路径
        if git_root:
            try:
                relative_path = self.cwd.relative_to(git_root)
                context['relative_path'] = str(relative_path) if str(relative_path) != '.' else ''
                context['git_root'] = str(git_root)
            except ValueError:
                # cwd 不在 git_root 下
                pass

        return context


def main():
    """主函数"""
    import argparse

    parser = argparse.ArgumentParser(
        description='捕获代码上下文信息（Git、项目等）'
    )
    parser.add_argument(
        '--cwd',
        type=str,
        default=None,
        help='工作目录（默认为当前目录）'
    )
    parser.add_argument(
        '--pretty',
        action='store_true',
        help='格式化输出 JSON'
    )

    args = parser.parse_args()

    # 捕获上下文
    capturer = CodeContextCapture(cwd=args.cwd)
    context = capturer.capture()

    # 输出 JSON
    if args.pretty:
        print(json.dumps(context, indent=2, ensure_ascii=False))
    else:
        print(json.dumps(context, ensure_ascii=False))

    return 0


if __name__ == '__main__':
    sys.exit(main())
