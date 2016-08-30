# [My Bot](https://telegram.me/MobinDev)
# Features

* **A powerful antispam system with custom sensitivity for each group**
* **Multiple realms (admin groups)**
* **Recalcitrant to any kind of spamming (X/Y bots, name/photo changers, etc.)**
* **Global banning**
* **Broadcast to all groups**
* **Group and  links**
* **Kick, ban and unban by reply**
* **Groups, ban and global ban list**
* **Logging anything that happens in a group**
* **Invitation by username**
* **Group administration via private messages**
* **Only mods, owner and admin can add bots in groups**
* **Arabic lock**
* **Lock TgService**
* **Chat list**
* **And more!**


#نصب روبات

```sh
# میریم برای نصب روبات
cd $HOME
git clone https://github.com/MobinDehghani/TeleSeed-Perfect.git -b supergroups
cd TeleSeed
chmod +x launch.sh
./launch.sh install
./launch.sh # شماره را وارد کنید و وارد اکانت شوید
```

### دستورات لازم

بعد از اینکه روبات آنلاین شد به پیوی روبات رفته و واژه "id" را ارسال نمایید

Open ./data/config.lua and add your ID to the "sudo_users" section in the following format:
```
  sudo_users = {
    110626080,
    103649648,
    111020322,
    0,
    YourID
  }
```
Then restart the bot.

Create a realm using the `!createrealm` command.


* * *

# About Me

[Mobin Dehghani](https://github.com/MobinDehghani) ([Telegram](https://telegram.me/MobinDev))
