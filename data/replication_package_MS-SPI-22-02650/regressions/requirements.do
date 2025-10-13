capture program drop check_and_install
program define check_and_install
    syntax anything
    local pkg_name `anything'
    local pkg_command `pkg_name' // Assuming the package name is the same as its command

    capture qui which `pkg_command'
    local rc = _rc

    if `rc' != 0 {
        display "Installing `pkg_name'..."
        ssc install `pkg_name', replace
    }
    else {
        display "`pkg_name' is already installed."
    }
end
check_and_install outreg2
check_and_install reghdfe
check_and_install ftools
