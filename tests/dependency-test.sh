describe "dependency"

before() {
    export JUMBO_INCLUDE=1
    . ./jumbo
}

to_pkg() {
    awk 'BEGIN{FS=" *-> *"}{sub(" *", "", $1); if ($1 != "") printf ("%s\t1\t1\t1\t%s\n", $1, $2);}'
}

get_dep() {
    deps="$1"
    shift
    echo "$deps" | to_pkg | _get_all_deps_raw "$@" | xargs
}

it_simple_dependency1() {
    local deps="
    a
    b
    c
    "
    test "$(get_dep "$deps" a)" == "a"
}

it_simple_dependency2() {
    local deps="
    a -> b
    b
    c
    "
    test "$(get_dep "$deps" a)" == "b a"
}

it_simple_dependency3() {
    local deps="
    a -> b c
    b
    c
    "
    test "$(get_dep "$deps" a)" == "b c a"
}

it_simple_dependency4() {
    local deps="
    a -> b c
    b -> c
    c
    "
    test "$(get_dep "$deps" a)" == "c b a"
}

it_simple_dependency5() {
    local deps="
    a -> b c
    b -> c
    c
    "
    test "$(get_dep "$deps" a c)" == "c b a"
}

it_complex_dependency1() {
    local deps="
    a -> b c d
    b -> c d e
    c -> e
    d -> f g h
    e -> f
    f
    g
    h
    "
    test "$(get_dep "$deps" a)" == "f e g h c d b a"
}

it_complex_dependency2() {
    local deps="
    a -> b c
    b -> d e
    c -> b e f
    d
    e -> f
    f -> d
    g
    h
    "
    test "$(get_dep "$deps" a b h)" == "d f e b c a h"
}
