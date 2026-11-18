import subprocess
from pathlib import Path





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
repo_path = Path("/home/ni/ni/git/backup")

subprocess.run(
        ["git", "pull"],
        cwd=repo_path,
        capture_output=True,
        text=True
    )

subprocess.run(
        ["git", "add", "-A"],
        cwd=repo_path,
        capture_output=True,
        text=True
    )

subprocess.run(
        ["git", "commit", "-m", "自动提交"],
        cwd=repo_path,
        capture_output=True,
        text=True
    )

subprocess.run(
        ["git", "push"],
        cwd=repo_path,
        capture_output=True,
        text=True
    )