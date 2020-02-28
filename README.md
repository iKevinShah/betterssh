
# Better SSH

PoC content to have all public servers ssh into container and take it from there.
  

## Get image
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

I will be writing soon :D