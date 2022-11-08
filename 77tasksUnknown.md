1. Załóż jednym poleceniem (nie interaktywnie!) użytkownika o nazwie ‘Marian’.
Spraw, aby jego główną grupą użytkownika była ‘zarzad‘, a grupy pomocnicze to
‘adm’ oraz ‘audio’. Marian ma mieć powłokę ustawioną na /bin/sh.
Podpowiedź: man useradd

```bash

for i in zarzad adm audio; do sudo groupadd $i; done && sudo useradd marian -g zarzad -G adm,audio -s /bin/sh
```