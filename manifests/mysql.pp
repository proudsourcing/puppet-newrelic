define newrelic::mysql(
	$server_name = "heps3.proudsourcing.de mysql",
	$host = "localhost",
	$metrics = "status,newrelic",
	$user = "root",
	$passwd = "FEyC0YCBs26c",
	$newrelic_license_key = "9f7e5cb90f3de341cc19a984e2c0fc43b68555c3"
){
	include newrelic

	exec { "apt-get update":
	    command => "/usr/bin/apt-get update",
	}

	package { 'openjdk-6-jdk': ensure => latest, subscribe => Exec["apt-get update"] }

	file{ "/etc/newrelic/mysql": 
		ensure => "directory",
		subscribe => Package["openjdk-6-jdk"]
	}

	file { "/etc/newrelic/mysql/newrelic_mysql_plugin-1.0.9.tar.gz":
	    ensure => present,
	    source => "puppet:///modules/newrelic/newrelic_mysql_plugin-1.0.9.tar.gz",
	    subscribe => File["/etc/newrelic/mysql"]
	}

	exec {"/bin/tar zxvf newrelic_mysql_plugin-1.0.9.tar.gz":
		cwd => "/etc/newrelic/mysql",
		subscribe => File["/etc/newrelic/mysql/newrelic_mysql_plugin-1.0.9.tar.gz"]
	}

	file {"/etc/newrelic/mysql/newrelic_mysql_plugin-1.0.9/config/newrelic.properties":
		ensure => present,
		content => template("newrelic/newrelic.properties.erb"),
		subscribe => Exec["/bin/tar zxvf newrelic_mysql_plugin-1.0.9.tar.gz"]
	}

	file {"/etc/newrelic/mysql/newrelic_mysql_plugin-1.0.9/config/mysql.instance.json":
		ensure => present,
		content => template("newrelic/mysql.instance.json.erb"),
		subscribe => Exec["/bin/tar zxvf newrelic_mysql_plugin-1.0.9.tar.gz"]
	}

	
	exec {"/usr/bin/java -jar /etc/newrelic/mysql/newrelic_mysql_plugin-1.0.9/newrelic_mysql_plugin-1.0.9.jar >> /etc/newrelic/mysql/newrelic_mysql_plugin-1.0.9/log.txt":
		subscribe => File["/etc/newrelic/mysql/newrelic_mysql_plugin-1.0.9/config/mysql.instance.json"]
	}
}