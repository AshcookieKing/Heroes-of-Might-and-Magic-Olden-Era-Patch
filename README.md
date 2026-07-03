# SimTurnsAI Patch — Olden Era

Патч для **Heroes of Might and Magic: Olden Era**.  
Убирает раздражающую штуку: simultaneous / realtime ходы больше **не отключаются**, когда вы просто видите бота.  
У живых игроков поведение **не меняется** — как в ваниле.

Автор: **Imagundi**  
Steam: https://steamcommunity.com/id/Imagundi/  
Boosty (если хочется кинуть на печенье): https://boosty.to/imagundi

---

## Скачать

В [Releases](https://github.com/AshcookieKing/Heroes-of-Might-and-Magic-Olden-Era-Patch/releases) лежит один файл:

**`SimTurnsAI_Patch_Setup_v1.0.5.exe`**

Его и кидайте друзьям. Больше ничего не нужно.

---

## Установка

1. Закройте игру (и лаунчер, если открыт).
2. Запустите `SimTurnsAI_Patch_Setup_v1.0.5.exe`.
3. Укажите папку игры — там, где `HeroesOldenEra.exe` и `GameAssembly.dll`.  
   Если exe лежит прямо в папке игры, путь часто подставится сам.
4. Жмите «Далее» → «Установить».
5. На последнем экране — кнопки Steam и Boosty, если интересно.

Повторная установка после патча Steam: снова тот же exe.  
Или: Пуск → SimTurnsAI Patch → «Povtornaya ustanovka».

---

## Мультиплеер

Патч **клиентский**. Ставится **у каждого** человека в лобби, не только у хоста.  
Иначе у кого-то realtime будет падать на ботах, у кого-то нет — получите кашу.

Перед каткой нормально спросить в чате: «все поставили патч?»

---

## Откат

Пуск → **SimTurnsAI Patch** → **Otkat patcha**  

Или из папки патча (если ставили zip-вариант): `ОТКАТ.bat`  
Вернёт `GameAssembly.dll` из бэкапа `GameAssembly.dll.simturns_backup`.

---

## Что меняется на диске

| Файл | Что |
|------|-----|
| `GameAssembly.dll` | 3 байта — логика realtime + тип стороны |
| `GameAssembly.dll.simturns_backup` | копия оригинала при первой установке |
| `SimTurnsAI_Patch.installed` | маркер в папке игры |

---

## Сборка установщика самому

Нужны: Python 3 + Pillow, [Inno Setup 6](https://jrsoftware.org/isdl.php).

```bat
cd SimTurnsAI_Patch
BUILD_SETUP.bat
```

На выходе: `SimTurnsAI_Patch_Setup_v1.0.5.exe` в корне репозитория / на уровень выше папки патча.

---

## Если не ставится

- Игра запущена — закройте полностью.
- Не та папка — нужен корень, не `Bin` и не документы.
- После крупного обновления игры патч может не подойти — напишите автору в Steam, укажите дату обновления.

---

## Лицензия / ответственность

Неофициальный патч, не связан с Ubisoft / Unfrozen.  
Ставите на свой страх и риск. Для себя и друзей в приватных играх.
