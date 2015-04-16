#!/usr/bin/env bats

run_install_package_test() {
  run apt-cache policy $1
  [ $status -eq 0 ]
  [ "$(echo $output | grep Installed: | awk '{print $2}')" != "(none)" ]
}

@test "apache2 must be installed" {
  run_install_package_test "apache2"
}

@test "git-core must be installed" {
  run_install_package_test "git-core"
}

@test "curl must be installed" {
  run_install_package_test "curl"
}

@test "unzip must be installed" {
  run_install_package_test "unzip"
}

@test "/etc/apache2/ports.conf must exist" {
  [ -f /etc/apache2/ports.conf ]
}

@test "/etc/apache2/sites-available/default* must exist" {
  if [ "x`lsb_release -si`" = "xUbuntu" -a "x`lsb_release -sr`" = "x14.04" ]; then
    [ -f /etc/apache2/sites-available/default.conf ]
  else
    [ -f /etc/apache2/sites-available/default ]
  fi
}

# pending
# apache2 must be enabled

@test "/var/www/index.html must exist" {
  [ -f /var/www/index.html ]
}

@test "/var/www/img must exist" {
  [ -d /var/www/img ]
}

@test "apache2 must be running" {
  ps ax | grep '[ a]pache2'
}
