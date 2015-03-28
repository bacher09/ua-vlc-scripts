ua-vlc-scripts
=========

В данном репозитарии находятся плагин для работы с сайтами fs.to и ex.ua
в плейере vlc. Данные сервисы работают только на територии Украины (возможно
России, Беларусии, Казахстана).

Уставновка
----------

Скопируйте файлы с каталога `playlist`:

* Пользователям Windows: в `%ProgramFiles%\VideoLAN\VLC\lua\playlist\`
(для глобальной установки) либо `%APPDATA%\vlc\lua\playlist\`
(уставновка для одного пользователя)

* Пользователям Linux:  `/usr/lib/vlc/lua/playlist/` (глобально) или 
`~/.local/share/vlc/lua/playlist/`

* Пользователям Mac OS X: `/Applications/VLC.app/Contents/MacOS/share/lua/playlist/`


Использование
-------------

Откройте страницу с конетом на fs.to либо ex.ua в браузере. Скопируйте ссылку
и перейдите в vlc. Нажмите <kbd>Ctrl</kbd>+<kbd>N</kbd>
(в OS X <kbd>⌘</kbd>+<kbd>N</kbd>) и вставьте ссылку в меню, нажмине `Ok`.

![Screenshot][screenshot]

Настройка
---------

Если вы начнёте проигрывать видео через http и поставите его на паузу на долгое
время, то можете наблюдать как после востановления проигрывания оно начинает
играть с начала. Для того что-бы это исправить необходимо поставить одну опцию 
в настройках. Нажмите <kbd>Ctrl</kbd>+<kbd>P</kbd> (<kbd>⌘</kbd>+<kbd>,</kbd>
в OS X) что-бы войти в настройки. Выберите продвинутые настройки. Дальше
перейдите в меню `Модули ввода` -> `HTTP(S)` и включите опцию
`Автоматически востанавливать соединение`.

![Опция][option_osx]
![Опция][option]

Лицензия
--------
GPLv2

[screenshot]: https://raw.githubusercontent.com/bacher09/ua-vlc-scripts/master/screenshots/screenshot.png
[option]: https://raw.githubusercontent.com/bacher09/ua-vlc-scripts/master/screenshots/option.png
[option_osx]: https://raw.githubusercontent.com/bacher09/ua-vlc-scripts/master/screenshots/option_osx.png
