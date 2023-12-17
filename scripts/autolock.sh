pkill xautolock

xautolock -time 10 -locker "swaylock -i ~/.cache/current_wallpaper.jpg" -notify 30 -notifier "notify-send 'Screen will be locked soon.' 'Locking screen in 30 seconds'"
