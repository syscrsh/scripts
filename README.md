# scripting stuff

* This repo is intended as a collection of small scripts that I wrote for 
  various purposes.

* Most of them should be pretty self-explanatory and require little 
  modification to work. As they are written for myself, I don't care 
  too much about POSIX or portability in general.

* Modify the scripts as you see fit.
  Where they obviously need to be changed, I added **<>** markers.
  For example, replace **<HOSTNAME>** with a hostname of one of your servers that you can SSH into.

### Notes

[git_check.sh](git_check.sh)

- execute in the folder where you keep your git projects

- it will print a short status about each projects, letting you quickly 
  check the state of your various projects

[sync.sh](sync.sh)

- small helper script to make rsync easier to use in an automated fashion

- its not really designed for bi-directional syncronization, so deleting 
  data in a multi-client setup is a bit cumbersome, but possible (see below)

- in "normal" mode (with just the two locations specified), data is just copied
  to the remote server

- in "sync" mode (with the '-s' flag set), the client(s) push their data (as before) but
  also pull new data from the server that was added in the meantime by other clients

- if you want to delete data from multiple clients and servers, you would need to do the following

    - delete the unwanted data from one client

    - use the '-d' option to remove the data from the servers

    - then either manually remove the data from the other clients (preventing a renewed upload)

    - or completely delete the data on the other clients (so a new sync will pull down the new data)

    - this applies only to multi-client setups, for a single client just use the '-d' option

[status2.sh](status2.sh)

- a simple status script pulling some basic systeminfo

- should almost work out of the box on any Linux distro

- add ascii arts for your machines as you see fit
