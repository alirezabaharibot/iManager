# [iManager](https://telegram.me/iManager)

* **Tanzimate Sudo**

```sh
sudo apt-get update
sudo apt-get upgrade
```
```sh
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev make unzip git redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-dev
```
* **Nasb Bot**

```sh
cd $HOME 
git clone https://github.com/MobinDehghani/iManager 
cd iManager 
chmod +x launch.sh 
./launch.sh install 
./launch.sh  # شماره را وارد کنید و وارد اکانت شوید
```

* **Enable Kardan Auto launch**

```
killall screen 
killall tmux 
killall telegram-cli 
tmux new-session -s script "bash steady.sh -t" 
```

Finish :)

* * *
**By [Mobin Dehghani](https://telegram.me/mobindev)**
