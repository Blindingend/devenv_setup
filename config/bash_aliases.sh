#!/bin/bash

# Bash aliases for various functions

# hgrep - Extract header from a file and grep for a keyword
# Usage: hgrep "keyword" "file_path"
# Creates a new file named file_path.keyword.csv containing the header
# and grep results for the keyword
function hgrep() {
    if [ $# -ne 2 ]; then
        echo "用法: hgrep \"关键词\" \"文件路径\""
        return 1
    fi
    
    local keyword="$1"
    local file_path="$2"
    local output_file="${file_path}.${keyword}.csv"
    
    # 检查输入文件是否存在
    if [ ! -f "$file_path" ]; then
        echo "错误: 文件 '$file_path' 不存在"
        return 1
    fi
    
    # 判断是否为gz压缩文件
    if [[ "$file_path" == *.gz ]]; then
        # 对于gz文件，使用zcat和zgrep
        zcat "$file_path" | head -n 1 > "$output_file"
        zgrep "$keyword" "$file_path" >> "$output_file"
    else
        # 对于普通文件，使用head和grep
        head -n 1 "$file_path" > "$output_file"
        grep "$keyword" "$file_path" >> "$output_file"
    fi
    
    echo "已创建文件: $output_file"
    echo "包含头部行和包含 '$keyword' 的行"
}




# 添加此文件到您的 .bashrc 或 .bash_profile:
# 在您的 .bashrc 或 .bash_profile 中添加以下行:
# if [ -f ~/path/to/config/bash_aliases.sh ]; then
#     source ~/path/to/config/bash_aliases.sh
# fi 