describe "utils test"

before() {
    export JUMBO_INCLUDE=1
    . ./jumbo
    PKGNAME=pkgname_test
    PKGVER=pkgver_test
    PKGREL=pkgrel_test
    PKGDESC="pkgdesc test"
    PKGFILE=pkgfile_test
    PKGDEP1=pkgdep_test1
    PKGDEP2=pkgdep_test2
    PKGDEPS="$PKGDEP1 $PKGDEP2"
    PKGREALVER=$PKGVER-$PKGREL

    PKGNAME2=pkgname2_test
    PKGVER2=pkgver2_test
    PKGREL2=pkgrel2_test
    PKGDESC2="pkgdesc2 test"
    PKGFILE2=pkgfile2_test
    PKGREALVER2=$PKGVER2-$PKGREL2

    PKGLINE="$PKGNAME	$PKGREALVER	$PKGFILE	$PKGDESC	$PKGDEPS"
    PKGLINE2="$PKGNAME2	$PKGREALVER2	$PKGFILE2	$PKGDESC2	$PKGDEPS"
    LISTFILE="$PKGLINE
$PKGLINE2"
    _fetch() {
        echo "$LISTFILE"
    }
}

it_filter_install() {
    test "$(echo "$PKGLINE" | _filter_install)" == "$PKGFILE"
}
it_filter_desc() {
    test "$(echo "$PKGLINE" | _filter_desc)" == "$PKGNAME : $PKGDESC"
}
it_filter_desc_only() {
    test "$(echo "$PKGLINE" | _filter_desc_only)" == "$PKGDESC"
}
it_filter_name() {
    test "$(echo "$PKGLINE" | _filter_name)" == "$PKGNAME"
}
it_filter_name_ver() {
    test "$(echo "$PKGLINE" | _filter_name_ver)" == "$PKGNAME - $PKGREALVER"
}
it_filter_ver() {
    test "$(echo "$PKGLINE" | _filter_ver)" == "$PKGREALVER"
}
it_filter_depend() {
    test "$(echo "$PKGLINE" | _filter_depend)" == "$PKGDEPS"
}
it_filter_depend() {
    test "$(echo "$PKGLINE" | _filter_depend)" == "$PKGDEPS"
}
it_split_depend() {
    test "$(echo "$PKGLINE" | _filter_depend | _split_depend)" == "$PKGDEP1
$PKGDEP2"
}
it_can_get_by_name() {
    test "$(echo "$LISTFILE" | _get_by_name "$PKGNAME")" == "$PKGLINE"
}
it_can_get_list() {
    test "$(_get_list)" == "$PKGNAME $PKGFILE
$PKGNAME2 $PKGFILE2"
}
it_can_get_desc() {
    test "$(_get_desc)" == "$PKGNAME : $PKGDESC
$PKGNAME2 : $PKGDESC2"
}
it_can_get_version_desc() {
    test "$(_get_version_desc)" == "$PKGNAME $PKGREALVER $PKGDESC
$PKGNAME2 $PKGREALVER2 $PKGDESC2"
}

it_can_handle_param_to_lines() {
    test "$(_param_to_lines a b "c d" e f)" == "a
b
c d
e
f"
}
