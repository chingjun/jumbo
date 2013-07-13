# Jumbo 源格式

## 规范
Jumbo 源中，必须包含 list.tar.gz 文件和 packages 目录

list.tar.gz 的内容是将所有 jam 文件打包后生成（不在任何子目录下）

packages 目录下包含很多子目录，每个子目录为各个包的 pkgname，每个子目录下放置对应包所需的源文件

## 工具
将所有 jam 文件放置再 installs 目录下，list.tar.gz 可用下列脚本生成

    #!/bin/sh
    cd $(dirname "$0")
    f="$PWD/tmp.tar"
    final="$PWD/list.tar.gz"

    cd "$PWD/installs"
    ls | while read i
    do
        pkgname_expected=${i%.jumbo}
        [ "$pkgname_expected" == "$i" ] && continue
        (
            . "$i" && [ "$pkgname" == "$pkgname_expected" ]
        ) || continue
        tar -rf "$f.tmp" "$i"
    done
    if [ -f "$f.tmp" ]
    then
        mv "$f.tmp" "$f"
        gzip "$f"
        mv "$f.gz" "$final"
    fi

## 示例
作为例子，下面给出一个 jumbo 源的文件列表

    ./packages
    ./packages/git
    ./packages/git/git-1.8.1.4.tar.gz
    ./packages/git/git-manpages-1.8.1.4.tar.gz
    ./packages/jumbo
    ./packages/jumbo/jumbo-0.6.1
    ./packages/jumbo/jumbo-bashrc-0.6.1
    ./packages/jumbo/jumborc-0.6.1
    ./packages/jumbo/bashrc-0.6.1
    ./installs
    ./installs/git.jumbo
    ./installs/jumbo.jumbo
    ./list.tar.gz

list.tar.gz 的文件内容如下

    $ tar -tzf list.tar.gz
    jumbo.jumbo
    git.jumbo