---
name: Miryoku 60_ansi_subset (row-shifted alphas, custom variant) + bottom-row layer-triggers
description: Альфи зсунуті вгору по канонічному 60_ansi_subset (number row = Miryoku top alphas, QWERTY row = Miryoku home з GACS, home row = Miryoku bottom alphas). Layer-triggers на фізичному bottom row — x=MEDIA, c=NAV, v=MOUSE, n=SYM, m=NUM, ,=FUN. Clipboard=WIN, CapsLock=Esc.
---

# Miryoku (row-shifted alphas + bottom-row layer-triggers) для kanata

## Context

Фінальна адаптація Miryoku для HyperX Alloy FPS Pro TKL ANSI — **гібрид**:

1. **Альфи зсунуті УГОРУ на одну фізичну row** (custom-variant `60_ansi_subset`):
   - ANSI number row → Miryoku top alphas (`q w e r t | y u i o p`)
   - ANSI QWERTY row → Miryoku home row + GACS mod-taps (`a s d f g | h j k l ;`)
   - ANSI home row → Miryoku bottom row (`z x c v b | n m , . /`) — **чисті літери, без layer-hold**

2. **Layer-triggers залишаються на ФІЗИЧНОМУ bottom row** (не shifted):
   - `x` = MEDIA hold
   - `c` = NAV hold
   - `v` = MOUSE hold
   - `n` = SYM hold
   - `m` = NUM hold
   - `,` = FUN hold

Це означає, що літери `x c v n m ,` доступні двома шляхами: через shifted-grid (physical `s d f h j k` = clean tap, без tap-hold delay) і через physical bottom row (physical `x c v n m ,` = tap з 200ms hold-check). Для швидкого набору — shifted; для layer-активації — bottom.

## Фізичний мапінг

### Row 1 (F-row)
Без змін: `esc f1..f12 prnt slck pause`.

### Row 2 (Number row) — Miryoku TOP alphas
| Physical | Tap | Hold |
|----------|-----|------|
| grv | як є | — |
| 1 | q | — |
| 2 | w | — |
| 3 | e | — |
| 4 | r | — |
| 5 | t | — |
| 6 | y | — |
| 7 | u | — |
| 8 | i | — |
| 9 | o | — |
| 0 | p | — |
| -, = | як є | — |
| bspc, ins, home, pgup | як є | — |

### Row 3 (QWERTY row) — Miryoku HOME + GACS
| Physical | Tap | Hold |
|----------|-----|------|
| tab | tab | — |
| q | a | **lmet** |
| w | s | **lalt** |
| e | d | **lctl** |
| r | f | **lsft** |
| t | g | — |
| y | h | — |
| u | j | **rsft** |
| i | k | **rctl** |
| o | l | **lalt** |
| p | ; | **rmet** |
| [, ], \, del, end, pgdn | як є | — |

### Row 4 (ANSI home row) — Miryoku BOTTOM alphas (plain)
| Physical | Tap | Hold |
|----------|-----|------|
| caps | **esc** | — |
| a | z | — |
| s | x | — |
| d | c | — |
| f | v | — |
| g | b | — |
| h | n | — |
| j | m | — |
| k | , | — |
| l | . | — |
| ; | / | — |
| ', ret | як є | — |

### Row 5 (ANSI bottom row) — LAYER TRIGGERS
| Physical | Tap | Hold |
|----------|-----|------|
| lsft, z | як є | — |
| **x** | x | **MEDIA** |
| **c** | c | **NAV** |
| **v** | v | **MOUSE** |
| b | b | — |
| **n** | n | **SYM** |
| **m** | m | **NUM** |
| **,** | , | **FUN** |
| ., / | як є (plain) | — |
| rsft, up | як є | — |

### Row 6 (Space row)
Без змін: `lctl lmet lalt spc ralt menu rctl left down right`. `spc` — простий (без layer-hold).

## Ключові дизайн-рішення

1. **Clipboard — WIN** (`C-z/x/c/v/y`).
2. **CapsLock → Esc**.
3. **Thumb-keys plain** (spc, ent, bspc, esc, tab, del без dual-function).
4. **Mouse buttons у MOUSE-layer**: ret=LMB (`mltp`), bspc=RMB (`mrtp`), del=MMB (`mmtp`).
5. **Transport у MEDIA-layer**: ret=`XX` (stop недоступний у kanata 1.11.0 — нема `KEY_STOPCD` keyname), bspc=mute, del=playpause.
6. **i/o swap у HRM**: physical `i` taps `k` (з rctl), physical `o` taps `l` (з lalt). У NAV: i=up, o=down. У MEDIA: i=volu, o=vold.
7. **Пропускаємо**: BUTTON-шар, RAlt/compose, DF(BASE/EXTRA/TAP), layer-lock.

## Файли

- `/home/danmar/WebstormProjects/dotfiles/.config/kanata/kanata.kbd` — основний конфіг.

## Per-layer cheat sheet (фізичні позиції)

### BASE
- **Number row 1-0**: видає `q w e r t y u i o p` (Miryoku top alphas). `grv`, `-`, `=` — як є.
- **QWERTY row q-p**: видає `a s d f g h j k l ;` (Miryoku home). Натиснути+утримати `q/w/e/r` = met/alt/ctl/sft; `u/i/o/p` = sft/ctl/alt/met.
- **Home row a-;**: видає `z x c v b n m , . /` (Miryoku bottom). Без hold-функції.
- **Bottom row x/c/v/n/m/,**: tap = літера; hold = MEDIA/NAV/MOUSE/SYM/NUM/FUN відповідно. `z/b/./ /` — звичайні літери.
- **CapsLock**: `esc` (без hold).

### NAV (hold `c`)
- Physical 6/7/9/0/- → `C-y` / `C-v` / `C-x` / `C-c` / `C-z` (rdo / pst / cut / cpy / und). Physical 8 = `_`, 1-5 = XX.
- Physical y/u/i/o/p → caps / left / up / down / right (курсор).
- Physical h/j/k/l/; → ins / home / pgdn / pgup / end (nav-block).
- Physical q/w/e/r → pure mods (lmet / lalt / lctl / lsft).

### MOUSE (hold `v`)
- Physical 6/7/9/0/- → clipboard (rdo/pst/cut/cpy/und). Physical 8 = `_`.
- Physical u/i/o/p → рух миші (left / up / down / right з acceleration).
- Physical bspc → RMB (`mrtp`); del → MMB (`mmtp`); ret → LMB (`mltp`).
- Physical q/w/e/r → pure mods.

### MEDIA (hold `x`)
- Physical u/i/o/p → prev / volu / vold / next.
- Physical bspc → mute; del → pp (playpause); ret → `XX` (stop недоступний).
- Physical q/w/e/r → pure mods.

### NUM (hold `m`)
- Лівий numpad grid:
  ```
  Number row 1-5:  [  7  8  9  ]
  QWERTY row q-t:  ;  4  5  6  =
  Home row a-g:    `  1  2  3  \
  ```
- `spc` → `0`.
- Права рука: pure-mods на u/i/o/p (rsft / lalt / rctl / rmet).

### SYM (hold `n`)
- Shifted NUM:
  ```
  Number row 1-5:  {  &  *  (  }
  QWERTY row q-t:  :  $  %  ^  +
  Home row a-g:    ~  !  @  #  |
  ```
- `spc` → `)`.
- Права рука: ті ж pure-mods.

### FUN (hold `,`)
- F-keys grid:
  ```
  Number row 1-5:  f12  f7   f8   f9   S-prnt(SysRq)
  QWERTY row q-t:  f11  f4   f5   f6   slck
  Home row a-g:    f10  f1   f2   f3   pause
  ```
- Права рука: ті ж pure-mods.

## Token-count check

Кожен `deflayer` = 86 токенів: 16 + 17 + 17 + 13 + 13 + 10. Відповідає `defsrc`.

## Як застосувати новий конфіг

Kanata запущена як **user-service** (`~/.config/systemd/user/kanata.service` enabled).

```bash
systemctl --user restart kanata          # БЕЗ sudo — це user-unit
systemctl --user status kanata           # перевірити Active: active (running)
journalctl --user -u kanata -n 30        # останні логи на випадок помилки
```

Не використовувати `sudo systemctl restart kanata` — це шукає system-level unit, якого немає.

**Rollback** якщо щось пішло не так:
```bash
cp ~/.config/kanata/kanata.kbd.bak ~/.config/kanata/kanata.kbd
systemctl --user restart kanata
```

## Верифікація

1. **Syntax**: `kanata --cfg ~/.config/kanata/kanata.kbd --check` → exit 0.
2. `bash scripts/verify.sh` → зелений (symlinks ок).
3. Перезапустити kanata. Перевірити:
   - **BASE typing**: physical `q` → `a`; `w` → `s`; `1` → `q`; `8` → `i`; `0` → `p`; `a` → `z`; `;` → `/`; physical `x` → `x` (з 200ms hold-check).
   - **HRM**: hold `r` (lsft) + tap `u` (`j`) → `Shift+J`. Hold `q` (lmet) + `u` → `Super+J`. Hold `i` (rctl) + tap `g` → `Ctrl+G`. Hold `o` (lalt) + tap `b` → `Alt+B`.
   - **NAV** (hold physical `c`): `y/u/i/o/p` → caps/left/up/down/right; `h/j/k/l/;` → ins/home/pgdn/pgup/end; `6/7/9/0/-` → C-y/v/x/c/z.
   - **MOUSE** (hold `v`): `u/i/o/p` → рух миші left/up/down/right; `ret/bspc/del` → LMB/RMB/MMB; `6/7/9/0/-` → clipboard.
   - **MEDIA** (hold `x`): `u/i/o/p` → prev/volu/vold/next; `bspc` → mute; `del` → pp.
   - **NUM** (hold `m`): `2/3/4` → 7/8/9; `w/e/r` → 4/5/6; `s/d/f` → 1/2/3; `spc` → 0; `t` → `=`; `g` → `\`; `1` → `[`; `5` → `]`; `a` → `` ` ``; `q` → `;`.
   - **SYM** (hold `n`): ті ж позиції, shifted-символи; `spc` → `)`.
   - **FUN** (hold `,`): F-keys.
4. **Rolling**: швидкий набір не активує layer через `tap-hold-release` (layer тільки якщо натиснути-і-відпустити іншу клавішу до відпускання trigger'а).
5. **Shifted-vs-bottom для `x c v n m ,`**: tap physical `s` → `x` чисто, без затримки. Tap physical `x` → `x` з 200ms hold-check.

## Аварійний exit

Lctrl+Spc+Esc (фізичні defsrc keys).

## Mapping KMonad → kanata

| KMonad                              | kanata                                 |
|-------------------------------------|----------------------------------------|
| `tap-hold-next-release 200 T H`     | `(tap-hold-release 200 200 T H)`       |
| `layer-toggle X`                    | `(layer-while-held X)`                 |
| `U_NA` / `U_NU` / `U_NP`            | `XX` (no-op) / `_` (fall-through)      |
| `U_UND/CUT/CPY/PST/RDO` (WIN)       | `C-z/x/c/v/y`                          |
| `kp4/2/8/6` (XKB MouseKeys)         | `(movemouse-accel-* 10 1000 2 20)`     |
| `#(kp- kp5)` (LMB macro)            | `mltp`                                 |
| `playpause/prev/next/vold/volu/...` | `pp/prev/next/vold/volu/mute`          |
