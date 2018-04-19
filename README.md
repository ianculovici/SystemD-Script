# SystemD Script Example

This example shows a shell script that can be called in a SystemD service and how to setup the service itself. For CentOS, SystemD was introduced in CentOS 7.0 and represents a change from the way services were managed before (init.d).
The main script (file) that is being called by the services and addresses all the commands is called here ```systemd_example.sh```.

The script calls another script called ```sample_service.sh```, which can be any command that starts the program that runs as a service. This particular script or program does not have to accept commands like start and stop, since the main service script (systemd_example.sh) implements those.

This can be tested by running commands like:
```
systemd_example.sh start
```
```
systemd_example.sh status
```
```
systemd_example.sh stop
```
```
systemd_example.sh restart
```
Once confirming that these commands work, the service can be implemented. The service file needs to be created as ```/etc/systemd/system/sample_service.service```.

Once this file is created, the only thing left is to enable the service (make it automatically start on reboot) and start/stop as a service using the SystemD command.
```
systemctl enable sample_service
```
```
systemctl start sample_service
```
```
systemctl stop sample_service
```


See more details at https://dataandtechnology.wordpress.com/2018/03/01/systemd-service-and-script-example/.
