Install GNUU-User on LXD CONTAINER
==================================

```
lxc launch images:opensuse/13.2/amd64 gnuuuser
lxc file push deploy-gnuuuser.sh gnuuuser/
lxc exec gnuuuser -- bash /deploy-gnuuuser.sh
```
