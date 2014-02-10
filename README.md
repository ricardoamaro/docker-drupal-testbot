docker-drupal-testbot
=====================

This repo contains a recipe for making a [Docker](http://docker.io) container for Drupal, using Linux, Apache and MySQL. 
To build, make sure you have Docker [installed](http://www.docker.io/gettingstarted/).

This will try to go in line with [Drupal automated-testing](https://drupal.org/automated-testing).


## Install docker:
```
curl get.docker.io | sudo sh -x
```

## Clone this repo somewhere, 
```
git clone {thisrepo}
cd docker-drupal-testbot
```
#and then run
```
./test.sh
```
This will check if you already created the testbot docker image.
Then it will the tests after creating the image or just use the existing one.


Note: the latest Drupal version will be added each time you create the image.
If you need to remove the old image just run:
```
sudo docker images
sudo docker rmi {imageID}
```

### Clean up
While i am developing i use this to rm all old instances
```
sudo docker ps -a | awk '{print $1}' | xargs -n1 -I {} sudo docker rm {}
``` 

## Contributing
Feel free to fork and contribute to this code. :)

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

