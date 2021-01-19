package	{ "openssh-server":	ensure => "installed" }

service	{ "ssh":		ensure => "running",
				enable => "true",
				require => Package["openssh-server"]
}

augeas { "configure_sshd":
	context	=> "/files/etc/ssh/sshd_config",
	changes	=>	[ 	"set PasswordAuthentication yes",
				"set UsePam yes"
			],
	require	=> Package["openssh-server"],
	notify	=> Service["ssh"]
}