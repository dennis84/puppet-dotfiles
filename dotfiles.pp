Exec {
  path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/" ]
}

$libs = [
  "acl",
  "git",
  "tig",
  "mercurial",
  "zsh",
  "tmux",
  "build-essential",
  "cmake",
  "python-dev",
  "automake",
  "pkg-config",
  "libpcre3-dev",
  "zlib1g-dev",
  "liblzma-dev",
]

package { $libs:
  ensure => present,
}

exec { "clone-dotfiles":
  user => "vagrant",
  cwd => "/home/vagrant/",
  command => "git clone https://github.com/dennis84/dotfiles.git",
  require => Package["git"],
  logoutput => true,
}

exec { "install-dotfiles-vendors":
  user => "vagrant",
  cwd => "/home/vagrant/dotfiles/scripts/",
  command => "sh install-vendors.sh",
  require => Exec["clone-dotfiles"],
  logoutput => true,
}

exec { "install-dotfiles-symlinks":
  user => "vagrant",
  cwd => "/home/vagrant/dotfiles/scripts/",
  command => "sh install-symlinks.sh",
  require => Exec["install-dotfiles-vendors"],
  logoutput => true,
}

exec { "install-vim":
  user => "vagrant",
  cwd => "/home/vagrant/dotfiles/scripts/",
  command => "sh vim-install.sh",
  logoutput => true,
  require => [
    Package["mercurial"],
    Package["python-dev"],
    Exec["clone-dotfiles"]],
}

exec { "clone-vim-config":
  user => "vagrant",
  cwd => "/home/vagrant/",
  command => "git clone https://github.com/dennis84/vim-config.git",
  require => Exec["install-vim"],
  logoutput => true,
}

exec { "install-vim-config":
  user => "vagrant",
  cwd => "/home/vagrant/vim-config/",
  command => "sh install.sh",
  require => Exec["clone-vim-config"],
  logoutput => true,
}

exec { "install-vim-bundles":
  user => "vagrant",
  command => "vim +BundleInstall! +qall",
  require => [
    Exec["install-vim-config"],
    Exec["install-vim"]],
}

exec { "install-vim-you-complete-me":
  user => "vagrant",
  cwd => "/home/vagrant/vim-config/bundle/YouCompleteMe/",
  command => "bash install.sh",
  logoutput => true,
  require => [
    Package["build-essential"],
    Package["cmake"],
    Package["python-dev"],
    Exec["install-vim-bundles"]],
}

exec { "clone-silver-searcher":
  user => "vagrant",
  cwd => "/home/vagrant/",
  command => "git clone https://github.com/ggreer/the_silver_searcher.git",
  logoutput => true,
  require => Package["git"],
}

exec { "build-silver-searcher":
  user => "vagrant",
  cwd => "/home/vagrant/the_silver_searcher",
  command => "sh build.sh",
  logoutput => true,
  require => [
    Exec["clone-silver-searcher"],
    Package["automake"],
    Package["pkg-config"],
    Package["libpcre3-dev"],
    Package["zlib1g-dev"],
    Package["liblzma-dev"]],
}

exec { "make-silver-searcher":
  user => "vagrant",
  cwd => "/home/vagrant/the_silver_searcher",
  command => "sudo make install",
  logoutput => true,
  require => Exec["build-silver-searcher"],
}

file { "/etc/default/locale":                                                   
  content => 'LC_ALL="en_US.UTF-8"',                                            
}

exec { "chsh -s /usr/bin/zsh vagrant":
  unless  => "grep -E '^vagrant.+:/usr/bin/zsh$' /etc/passwd",
  require => Package["zsh"],
}
