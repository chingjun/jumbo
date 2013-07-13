# jam

Jumbo application metafile

## 什么是 jam?

制作软件包需要有描述脚本, 描述如何构建和安装这个软件, 我们称其为元信息. jam 就是 jumbo 中软件的元信息文件.

我们从"站在巨人肩膀上"的角度出发, 决定继承 Arch PKGBUILD 的规范并做少量修改. 这样做有以下优势:

* 学习成本低. 相较于 Debian/Redhat 的包描述, Arch 的包描述非常简单, 只要会手工编译就能写, 几乎无学习成本.
* 资源非常丰富. Arch 官方以及 AUR 提供了大量现成的 PKGBUILD, 稍加修改即可使用.

## jam 长什么样子?

jam 的文件名和包名相同, 扩展名为 `.jumbo`, 本质上是一个 Shell 脚本. 

### 一个简单的 jam 样例: socat.jumbo

```bash
pkgname=socat
pkgver=1.7.2.0
pkgrel=1
pkgdesc="Multipurpose relay"
depends=('readline') # missdepends=('openssl')
sources=("${JUMBO_REPO}/packages/${pkgname}/${pkgname}-${pkgver}.tar.gz")
md5sums=('0565dd58800e4c50534c61bbb453b771')

jumbo_install() {
  cd "${srcdir}/${pkgname}-${pkgver}"

  ./configure --prefix="${JUMBO_ROOT}" \
	  --mandir="${JUMBO_ROOT}/share/man"
  cat - >> config.h <<EOF
#ifndef HAVE_LINUX_ERRQUEUE_H
#define HAVE_LINUX_ERRQUEUE_H 1
#endif
EOF
  make
  make DESTDIR="${pkgdir}" install
}

# vim:set ft=sh ts=2 sw=2 et:
```

### 一个复杂的 jam 样例: vim.jumbo

```bash
pkgname=vim
pkgver=7.3.495
pkgrel=1
_versiondir=vim73
pkgdesc='Vi Improved, a highly configurable, improved version of the vi text editor'
depends=('xz' 'ncurses' 'python' 'perl') # missdepends=('ruby' 'lua' 'gpm')
sources=("${JUMBO_REPO}/packages/${pkgname}/${pkgname}-${pkgver}.tar.xz"
         "${JUMBO_REPO}/packages/${pkgname}/pythoncomplete.vim"
         "${JUMBO_REPO}/packages/${pkgname}/archlinux.vim"
         "${JUMBO_REPO}/packages/${pkgname}/vimrc")
md5sums=('d6170ee30260b37ceab04a1b50d54e16'
         '6e7adfbd5d26c1d161030ec203a7f243'
         '10353a61aadc3f276692d0e17db1478e'
         'e57777374891063b9ca48a1fe392ac05')

jumbo_install() {
  cd "${srcdir}"
  xz -c -d "${pkgname}-${pkgver}.tar.xz" | tar -x

  cd "${srcdir}/${pkgname}-${pkgver}"

  echo "#define SYS_VIMRC_FILE \"${JUMBO_ROOT}/etc/vimrc\"" >> src/feature.h

  ./configure --prefix="${JUMBO_ROOT}" \
    --localstatedir="${JUMBO_ROOT}/var/lib/vim" \
    --with-features=big \
    --enable-gpm --enable-acl --with-x=no \
    --disable-gui --enable-multibyte --enable-cscope \
    --enable-netbeans --enable-perlinterp --enable-pythoninterp \
    --disable-python3interp --disable-rubyinterp --disable-luainterp \
    --without-local-dir

  make
  make DESTDIR="${pkgdir}" install

  # Don't forget logtalk.dict
  install -Dm644 "${srcdir}/${pkgname}-${pkgver}/runtime/ftplugin/logtalk.dict" \
    "${pkgdir}/${JUMBO_ROOT}/share/vim/${_versiondir}/ftplugin/logtalk.dict"

  # fix FS#17216
  sed -i 's|messages,/var|messages,/var/log/messages.log,/var|' \
    "${pkgdir}/${JUMBO_ROOT}/share/vim/${_versiondir}/filetype.vim"

  # make Aaron happy
  install -Dm644 "${srcdir}/pythoncomplete.vim" \
    "${pkgdir}/${JUMBO_ROOT}/share/vim/${_versiondir}/autoload/pythoncomplete.vim"

  # rc files
  install -Dm644 "${srcdir}/vimrc" "${pkgdir}/${JUMBO_ROOT}/etc/vimrc"
  install -Dm644 "${srcdir}/archlinux.vim" \
    "${pkgdir}/${JUMBO_ROOT}/share/vim/vimfiles/archlinux.vim"

  # rgb.txt file
  install -Dm644 "${srcdir}/${pkgname}-${pkgver}/runtime/rgb.txt" \
    "${pkgdir}/${JUMBO_ROOT}/share/vim/${_versiondir}/rgb.txt"
}

# vim:set ft=sh ts=2 sw=2 et:
```

## jam 里面的各项都是什么意思?

下列描述中, 使用 **要求**(MUST/REQUIRED) 和 **建议**(SHOULD/RECOMMENDED) 进行描述, 解释可参考 [RFC 2119](http://www.ietf.org/rfc/rfc2119.txt).

* `pkgname`: 包名
    * 要求: 只允许使用小写英文字母, 数字, 减号.
        * 如: python, python26, apr-util.
* `pkgver`: 版本号, `pkgrel`: 构建号
    * `${pkgver}-${pkgrel}` 即为包版本号.
    * 建议: `pkgver` 尽量与软件本身自带的版本号一致. 若无版本号(如民间脚本或内部程序), 则从 1 开始.
    * 要求: `pkgrel` 从 1 开始, 递增编号.
    * 要求: 更新包描述时
        * 只进行格式调整等无实质更新的修改, 不需要触发用户更新, 则 `pkgver` 和 `pkgrel` 不变. 此更新称为 Misc.
        * `pkgver` 没有改变, 则 `pkgrel` 加 1, 触发用户更新. 此更新称为 Minor Upgrade.
        * `pkgver` 发生改变, 则 `pkgrel` 重置为 1, 触发用户更新. 此更新称为 Major Upgrade.
* `pkgdesc`: 包描述
    * 要求: 使用英语.
    * 建议: 直接使用 Arch PKGBUILD 中的描述.
* `depends`: 包依赖
    * 要求: 添加所有直接依赖.
        * 如: git 直接依赖 python 和 expat, 虽然 python 也依赖 expat, 但仍要把 expat 写入 git 的依赖中.
    * 要求: 若有部分依赖使用的是系统提供的版本, 将其写入注释中的 `missdepends` 中备忘.
        * 如: git 依赖 openssl, 但我们使用系统提供的, 故将其写入 `missdepends` 中备忘.
    * 建议: 基于 Arch PKGBUILD 中的依赖进行修改.
* `sources`: 源码包下载地址
    * 要求: 同一个包的源代码全部放在 `${JUMBO_REPO}/packages/${pkgname}` 下.
* `md5sums`: 源码包的 MD5 签名值
    * 用于检验源码包是否正确
* `jumbo_install()`: 安装脚本
    * jumbo 会将源代码下载到 `${srcdir}` 目录中. `.tar`, `.tar.gz`, `.tar.bz2`, `.tgz`, `.tbz2` 等后缀的文件会自动解压.
    * jumbo 随后调用 `jumbo_install()` 进行编译和打包安装.
    * 要求: 通过 `--prefix`, `PREFIX` 等参数, 指定软件包最终将安装到 `${JUMBO_ROOT}`(相当于 `/usr`)下.
    * 要求: 通过 `DESTDIR` 等参数, 将软件包安装至 `${pkgdir}` 下供 jumbo 打包.
    * jumbo 最后将把 `${pkgdir}/${JUMBO_ROOT}` 下的内容安装到 `${JUMBO_ROOT}` 中.

## 怎么才能快速地写出 jam?

### 使用模板

下面是一个基于 `./configure`, `make`, `make install` 三步曲的模板:

```bash
pkgname=NAME
pkgver=VERSION
pkgrel=1
pkgdesc=""
depends=() # missdepends=()
sources=("${JUMBO_REPO}/packages/${pkgname}/${pkgname}-${pkgver}.tar.gz")
#sources=("${JUMBO_REPO}/packages/${pkgname}/${pkgname}-${pkgver}.tar.bz2")
md5sums=()

jumbo_install() {
  cd "${srcdir}/${pkgname}-${pkgver}"

  ./configure --prefix="${JUMBO_ROOT}"
  make
  make DESTDIR="${pkgdir}" install
}

# vim:set ft=sh ts=2 sw=2 et:
```

### 参考 Arch PKGBUILD

大部分的软件包都可以在 Arch 中找到现成的 PKGBUILD, 稍加修改即可初步成型.

请注意 PKGBUILD 与 jam 的几个不同之处:

* PKGBUILD 中的 `source` 在 jam 中是 `sources`.
* PKGBUILD 中的 `build()` 和 `package()` 在 jam 中合成为一个 `jumbo_install()`.
* PKGBUILD 中的 `makedepends` 在 jam 中需要作为 `depends` 来考虑.
* PKGBUILD 中的 `backups`, `conflicts`, `replaces`, `provides` 等在 jam 中都尚未提供支持.

#### 参考资源

* Arch 官方仓库: http://www.archlinux.org/packages/
* Arch AUR: https://aur.archlinux.org/
* PKGBUILD manpage: http://www.archlinux.org/pacman/PKGBUILD.5.html

### 本地调试技巧

* 将源码包放在本地工作目录，执行 `local-install` 时将自动使用本地同名文件.
* 使用 `file://` 指定源码包位置, 待正式发布时再修改为相应路径.
* 使用 `local-install` 命令配合 `-v` 参数测试 jam 是否正确: `jumbo local-install -v my-package.jumbo`

### 提交信息规范

* 格式: `<ACTION>: <PKG_VERSION>`
* `ACTION`, 共有以下四种
    * `NEW`: New. 新包
    * `MOD`: Modify. `pkgver` 和 `pkgrel` 都不改变时
    * `FIX`: Fix. `pkgver` 不变, `pkgrel` 改变时
    * `UPG`: Upgrade. `pkgver` 改变时
* `PKG_VERSION`, 即 `${pkgname} ${pkgver}-${pkgrel}`
