export JUMBO_ROOT="##JUMBO_ROOT##"
export PATH="$JUMBO_ROOT/bin:$PATH"
export MANPATH="$JUMBO_ROOT/share/man:$(manpath)"
[ -d "$JUMBO_ROOT/etc/bashrc.d" ] && for i in $(LC_ALL=C ls "$JUMBO_ROOT/etc/bashrc.d" | sed -e '/~$/d' -e '/\.swp$/d' -e '/\.bak$/d')
do
  i="$JUMBO_ROOT/etc/bashrc.d/$i"
  [[ -f $i && -r $i ]] && . "$i"
done
