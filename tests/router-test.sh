describe "routers"

before() {
    export JUMBO_INCLUDE=1
    . ./jumbo
    TEST_DESC="test_desc_only..."
    TEST_USAGE="test_usage_only..."
    TEST_RETURN="test_return_only..."
    TEST_ACTION="justfortest"
    jumbo_action_justfortest() {
        _desc "$TEST_DESC" || return 0
        _usage "$TEST_USAGE" || return 0
        echo "$TEST_RETURN" $1
    }
}

it_shows_desc() {
    test "$(_get_cmd_desc $TEST_ACTION)" == "$TEST_DESC"
}
it_shows_usage() {
    test "$(_get_cmd_usage $TEST_ACTION)" == "$TEST_USAGE"
}
it_can_run() {
    test "$(_run_cmd $TEST_ACTION 123)" == "$TEST_RETURN 123"
}
it_can_get_all_cmd() {
    _get_all_cmds | grep "^$TEST_ACTION$"
}
it_correctly_handles_cmd_exist() {
    _cmd_exist $TEST_ACTION
}
it_can_route() {
    test "$(_route $TEST_ACTION 1234)" == "$TEST_RETURN 1234"
}
it_can_route_with_action_not_exist() {
    (_route not_exist 1234 2>&1 | grep "Commands available") &&
    (_route not_exist 1234 2>&1 | grep "$TEST_ACTION") &&
    (_route not_exist 1234 2>&1 | grep "$TEST_DESC") &&
    true
}
it_can_show_help() {
    (_show_help 2>&1 | grep "Commands available") &&
    (_show_help 2>&1 | grep "$TEST_ACTION") &&
    (_show_help 2>&1 | grep "$TEST_DESC") &&
    true
}
it_can_show_help_of_specific_command() {
    (_show_help $TEST_ACTION 2>&1 | grep "Usage") &&
    (_show_help $TEST_ACTION 2>&1 | grep "$TEST_DESC") &&
    (_show_help $TEST_ACTION 2>&1 | grep "$TEST_USAGE") &&
    true
}
it_can_show_help_of_non_existing_command() {
    _show_help not_exist 2>&1 | grep "does not exist"
}
