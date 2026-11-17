#!/bin/bash

# 当前输入法
engine=$(ibus engine)

# 如果不是英文，模拟 Ctrl+Space
if [[ "$engine" != "xkb:us::eng" ]]; then
    ydotool key 29:1 57:1 57:0 29:0
fi

# 启动 shell
exec "$SHELL"
