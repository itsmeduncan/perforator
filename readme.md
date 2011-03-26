# Perforator

This is to benchmark some paths on a specific host. Right now, it is setup to 
login using the provided username and password to login to a Rails app that is
using the default Devise settings.

It runs every 5 minutes on the build server to get a baseline benchmark of our
page performance. 

### Todo
* Make it work with less specific setups.
* Make it more configurable:
  * Cleanup
  * Output
* Documentation  
* More features