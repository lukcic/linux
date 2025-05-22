# vim

`vimtutor`

Forgotten sudo: 

```sh
:w !sudo tee %
```

https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work

## Modes

- normal mode
- insert mode (i)
- replace mode (r)
- command-line mode (:)

SELECTION modes:
- visual mode  (v)
- visual line (Shift+v)
- visual block (Ctrl + v)

`~/.vimrc` - vim`s config file

### Normal mode

#### Navigation in normal mode

```sh
j - down
k- up
h - left
l - right

w - next word
b - beggining of word
e - end of the word

0 - beginning of the line 
$ - end of the line
^ - first non-blank character on the line

H - top of the screen
M - middle of the screen
L - bottom of the screen

Ctrl + U - moves up
Ctrl + D - move down

gg -  beginning of document
G - end of document

f + letter - moves for first appearance (wystąpienie) of letter (F - the same but left)
, and ; - navigating matches

/ + [word] - search, ? - backwards?
n - next match
N - prev match
```

## Commands

`:! [LINUX COMMAND]` - execute linux command in vim

```sh
i - inserting (left of carrot)
a - inserting (right of carrot)
o - inserting in new line below 
O - inserting in new line above

u - undo changes
Ctrl + r - redo changes

x - deleting sign
d + movement - deleting
   dw - delete word
   d$ - delete to end of the line
   d0 - delete to beginning of the line
dd - delete all line

r - replacing sign
c + movement - changing (delete + insert)
cc - change line

y - copy
yw - copy the word (yank word)
yy - copy line (yank yank)
p - paste

v - selecting the text (visual mode)
Ctrl+v - selecting blocks

4j  - hits j four times
ci' - change inside quotes '
ca' - change around quotes '

. - repeats the last command
~ - changes the upper/lowercase

sp - double windows
qa - close all windows
tabnew - new tab

ZZ - close & save
ZQ - close and not save

```

`ESC : set number` - enabling line numbers

`ESC : set -aste` - paste mode