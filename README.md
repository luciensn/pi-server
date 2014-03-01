pi-server
=========

### Installing Java

The latest Raspbian distribution may already have Java installed
	
	$ java -version

If that command is not recognized, install Java
	
	$ sudo apt-get update && sudo apt-get install oracle-java7-jdk

Once complete, reboot and check the version again to make sure it was installed properly
	
	$ sudo reboot
	$ java -version
