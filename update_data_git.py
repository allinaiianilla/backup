import subprocess
from pathlib import Path


def git_update(repo_path):
    """拉取远程代码，然后提交本地所有变更并推送"""

    repo_path = Path(repo_path).resolve()

    if not (repo_path / ".git").exists():
        raise RuntimeError(f"不是 Git 仓库: {repo_path}")

    def run_git(args):
        result = subprocess.run(
            ["git", *args],
            cwd=repo_path,
            capture_output=True,
            text=True
        )
    
        if result.stdout:
            print(result.stdout)
    
        if result.stderr:
            print(result.stderr)
    
        if result.returncode != 0:
            raise RuntimeError(
                f"Git 命令执行失败: {args}"
            )

    # 1. 先拉取远程代码
    run_git(["pull", "--ff-only"])

    # 2. 添加所有变更
    run_git(["add", "-A"])

    # 3. 检查是否有变更需要提交
    result = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        cwd=repo_path
    )

    if result.returncode == 1:
        # 4. 提交
        run_git(["commit", "-m", "自动提交"])
        
        # 5. 推送
        run_git(["push"])

    elif result.returncode == 0:
        print("没有需要提交的变更")

    else:
        raise RuntimeError("检查 Git 暂存区失败")

    print("Git 操作完成")


# 调用


# 更新备份文件,更新git仓库到远程

subprocess.run(
    "rm -rf /home/ni/ni/git/backup/debian/.config",
    shell=True,
    check=True
)
subprocess.run(
    "cp -r /home/ni/.config /home/ni/ni/git/backup/debian/",
    shell=True,
    check=True
)

git_update("/home/ni/ni/git/backup")
