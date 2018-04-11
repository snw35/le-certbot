# le-certbot

Cerbot docker container based on Alpine Linux.

This container will automate the **secure** deployment of Certbot in way that does not involve bind mounting the docker socket file into the container, or rely on any container that does.

I wrote this because I couldn't find a method of using letsencrypt with docker that was secure enough for production deployment. [JrCs' letsencrypt nginx proxy](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) may be convenient and popular, but I don't want the docker socket bind-mounted into any of my production containers, ever. I also don't want to use simp_le or other 3rd party letsencrypt tools - I want to use the official one developed by the EFF, and that means Certbot.

## How to use

This image can be used in two modes:

 1. __Webroot__ (recommended): automatically generate certificates through a companion webserver, and then run crond with 'certbot renew' once certificates exist to automatically renew them with the webroot method. See [le-docker](https://github.com/snw35/le-docker) for full docker-compose file.

 1. __Standalone__: run 'cerbot certonly' interactively for manual certificate generation, and then crond with 'certbot renew' to automatically renew them with the standalone method.


### Webroot

Please see my [le-docker](https://github.com/snw35/le-docker) repository for the docker-compose file that will automatically deploy this image alongside my le-nginx proxy container.

The advantage this will give you is that nginx can be configured to redirect all traffic to port 443 while still letting through the letsencrypt challenge, so you will have working SSL redirection.

### Standalone

To use the 'certbot certonly' command, run this image with direct arguments like an entrypoint:
```
docker run -it --mount source=le-certs,target=/etc/letsencrypt -p 80:80 snw35/le-certbot --standalone
```
This will allow you to interactively obtain certificates and will store them inside the le-certs named volume. If you then run the container with the volume mounted, it will detect your existing certificates and revert to running crond with 'certbot renew':
```
docker run -it --mount source=le-certs,target=/etc/letsencrypt -p 80:80 snw35/le-certbot
```
You can then mount the volume into your own containers to use the certificates at /etc/letsencrypt/(your domain)/live.
