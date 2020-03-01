
# Better SSH

PoC content to have all public servers ssh into container and take it from there.

## Get image locally 

Pull Image from docker hub. This will create user "ssh" and that would be used.
````bash
docker pull ikevinshah/betterssh:latest
````

## Alternate Method
 Pull the Dockerfile and build. The args supported are "user" and "password"

````bash
docker build --build-arg user=someuser --build-arg password=SomeVeryComplexP@ssw0rd -t 'betterssh:20200228' -f /path/to/Dockerfile .
````
The above command will build the image with ssh user `someuser` and password as `SomeVeryComplexP@ssw0rd`

## Run container

````bash
docker run --env password=SomeExtremelyComplexP@ssw0rd -p IP_ADDRESS:22:22 -it ssh:20200228
````
  

## Stop container

Use `Ctrl + \` to kill the container instance. `CTRL + C` does not stop `ssh` process.

# How is it better?

Consider this. There is a public facing web server (IP : `1.2.3.4`, the administrator connects to this IP to access the server via ssh)

Here's how this `betterssh` can be *slightly* better:  

_**NOTE:** You will need a non-ssh access to the server while configuring this._

1. Assign one of the IPs from the `docker0` network pool on server. 
````bash
Example: ip a
docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:e7:a2:9f:fc brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet 172.17.0.10/16 brd 172.17.255.255 scope global secondary noprefixroute docker0
       valid_lft forever preferred_lft forever
````
2. Edit the `sshd_config` on the server to only listen on that private address and restart the SSH service.
````
Example: cat /etc/ssh/sshd_config | grep ^Listen
Listen 172.17.0.10
````
3. Run the `betterssh` container. Publish the port `1.2.3.4:22` of the server to 22 on `betterssh` container. 
````bash
[root@docker01 ~]# docker run -d it --env password=Compl3x1ty --hostname $(hostname) -p 1.2.3.4:22:22 ikevinshah/betterssh:latest
bbe8100c936576de988c1779ad0a58c013bf5f764a2e6aa6e108567622314fa8
[root@docker01 ~]# docker ps
CONTAINER ID        IMAGE                         STATUS              PORTS                 NAMES
bbe8100c9365        ikevinshah/betterssh:latest   Up 20 seconds       1.2.3.4:22->22/tcp    practical_goldberg
[root@docker01 ~]# netstat -tulnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:5355            0.0.0.0:*               LISTEN      1229/systemd-resolv
tcp        0      0 1.2.3.4:22              0.0.0.0:*               LISTEN      3279/docker-proxy
tcp        0      0 172.17.0.10:22          0.0.0.0:*               LISTEN      2786/sshd
````
4. Now, all the new ssh connections to `1.2.3.4` will be to the container.
````bash
[root@docker02 ~]# ssh ssh@1.2.3.4
ssh@1.2.3.4's password:
Welcome!
docker01:~$ pwd
/home/ssh
````
5. From the container, an intruder is limited to the container. For legit users, they need to ssh twice. Once to the container and then from container to the base server.
````bash
[root@docker02 ~]# ssh ssh@1.2.3.4
ssh@1.2.3.4's password:
Welcome!
docker01:~$ pwd
/home/ssh
# This is the container!
docker01:~$ ssh root@172.17.0.10
root@172.17.0.10's password:
Welcome to the server!
[root@docker01 ~]#  
# This is the server!
````
6. Make sure to run the container on boot as a service because if not, on restarts, the SSH service will be running on private IP (172.17.0.10 in this example) while the container isn't running.

**Final thoughts:** This is just a proposal. There are different ways to achieve this without adding additional IPs (like changing SSH port on server to something like 2222 and mapping port 22 to container ssh).

Since this is a container, it is by definition, ephemeral in nature and all SSH logs will be lost on stops and restarts so there's that. You'll have to log `docker log` for the container.

Also the container process is run via root, so that's always not recommended. Although I will be looking to have that run via some non-root user.
