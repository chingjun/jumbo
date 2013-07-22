describe "compare version"

before() {
    export JUMBO_INCLUDE=1
    . ./jumbo
}

it_compare_version1() {
    test "$(_compare_version "1.0.0-1" "1.0.0-1")" == "0"
}
it_compare_version2() {
    test "$(_compare_version "1.0-1" "1.0-0")" == "1"
}
it_compare_version3() {
    test "$(_compare_version "1.0-0" "1.0-1")" == "-1"
}
it_compare_version4() {
    test "$(_compare_version "1-0.10" "1-0.3")" == "1"
}
it_compare_version5() {
    test "$(_compare_version "1-0.3" "1-0.10")" == "-1"
}
it_compare_version6() {
    test "$(_compare_version "1.0.10a-1" "1.0.10b-1")" == "-1"
}
it_compare_version7() {
    test "$(_compare_version "1.0.10b-1" "1.0.10a-1")" == "1"
}
it_compare_version8() {
    test "$(_compare_version "1.0.2b" "1.0.10a")" == "-1"
}
it_compare_version9() {
    test "$(_compare_version "1.0.10a" "1.0.2b")" == "1"
}
it_compare_version10() {
    test "$(_compare_version "1.0.a-1" "1.0.b-1")" == "-1"
}
it_compare_version11() {
    test "$(_compare_version "1.0.b-1" "1.0.a-1")" == "1"
}
it_compare_version12() {
    test "$(_compare_version "1.0.a-1" "1.0.aa-1")" == "-1"
}
it_compare_version13() {
    test "$(_compare_version "1.0.aa-1" "1.0.a-1")" == "1"
}
