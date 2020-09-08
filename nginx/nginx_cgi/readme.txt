##https://github.com/gnosek/fcgiwrap
unzip fcgiwrap-master.zip && cd fcgiwrap-master
autoreconf -i
./configure
make && make install
