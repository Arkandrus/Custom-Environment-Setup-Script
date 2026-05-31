# VSCode Keybindings Reference

> Leader key: `Space` (Vim Normal/Visual mode)
> Keyboard: Czech QWERTZ — bare number row produces `+ ě š č ř ž ý á í é` (no Shift needed)
> All bare number-row keys are remapped to their digit equivalents in Vim Normal mode (`+`=1, `ě`=2 … `é`=0)

---

## Pane & Tab Navigation

| Key | Action |
|-----|--------|
| `Ctrl+H` | Focus pane left |
| `Ctrl+J` | Focus pane below |
| `Ctrl+K` | Focus pane above |
| `Ctrl+L` | Focus pane right |
| `Tab` | Next editor in group *(Normal/Visual)* |
| `Shift+Tab` | Previous editor in group *(Normal/Visual)* |
| `Space B O` | Close all other editors |

---

## Editor Actions

| Key | Action |
|-----|--------|
| `Space W` | Save file |
| `Space Q` | Save & close editor |
| `Space S` | Split editor right |
| `Space V` | Split editor down |
| `Shift+K` | Show hover *(Normal)* |
| `Shift+J` | Move line(s) down *(VisualLine)* |
| `Shift+K` | Move line(s) up *(VisualLine)* |
| `Space C A` | Code action |
| `Space R N` | Rename symbol |
| `?` (Shift+`,`) | Outdent selected lines *(Visual / VisualLine)* |
| `_` (Shift+`-`) | Indent selected lines *(Visual / VisualLine)* |

---

## Go-To / Navigation

| Key | Action |
|-----|--------|
| `Space F F` | Quick open file |
| `Space F O` | Open folder |
| `Space F R` | Open recent |
| `Space G S` | Go to symbol in file |
| `Space G D` | Go to definition |
| `Space G R` | Go to references |
| `Space G I` | Go to implementation |

---

## Diagnostics

| Key | Action |
|-----|--------|
| `Space D N` | Next diagnostic / marker |
| `Space D P` | Previous diagnostic / marker |
| `Escape` | Close markers navigation *(editor focus)* |

---

## File Explorer

> These fire when the Explorer sidebar has focus (`filesExplorerFocus`).

| Key | Action |
|-----|--------|
| `Space E` | Toggle Explorer sidebar & focus files *(editor)* |
| `Space E` | Close Explorer sidebar & return to editor *(sidebar focus)* |
| `Enter` | Open file / toggle folder expand |
| `A` | New file |
| `Shift+A` | New folder |
| `R` | Rename |
| `C` | Copy |
| `X` | Cut |
| `P` | Paste |
| `D` | Delete |
| `S` | Open file to the side |
| `Shift+S` | Open file in split-down pane (closes others) |

---

## Terminal

| Key | Action |
|-----|--------|
| `Ctrl+Shift+J` | Toggle terminal panel |
| `Ctrl+Shift+J` | Next terminal *(terminal focus)* |
| `Ctrl+Shift+K` | Previous terminal *(terminal focus)* |
| `Ctrl+Shift+N` | New terminal *(terminal focus)* |
| `Ctrl+Shift+Q` | Kill terminal *(terminal focus)* |
| `Space J` | Toggle terminal panel *(Normal mode, editor focus)* |

---

## Harpoon

> Slots 1–5 use the Vim leader bindings in `settings.json` — handled by the Vim extension, safe in terminal.

| Key | Action |
|-----|--------|
| `Space A` | Add current editor to Harpoon |
| `Space H` | Edit Harpoon list |
| `Space P` | Harpoon quick-pick |
| `Space 1` *(bare `+`)* | Go to Harpoon slot 1 |
| `Space 2` *(bare `ě`)* | Go to Harpoon slot 2 |
| `Space 3` *(bare `š`)* | Go to Harpoon slot 3 |
| `Space 4` *(bare `č`)* | Go to Harpoon slot 4 |
| `Space 5` *(bare `ř`)* | Go to Harpoon slot 5 |

---

## Git / SCM

| Key | Action |
|-----|--------|
| `Space G G` | Open Source Control view |
| `Space G T` | Open new terminal |

### SCM panel bindings *(when SCM list has focus)*

| Key | Action |
|-----|--------|
| `S` | Stage file |
| `Shift+S` | Stage all |
| `U` | Unstage file |
| `Shift+U` | Unstage all |
| `X` | Discard changes |

---

## Testing

| Key | Action |
|-----|--------|
| `Space T T` | Focus Test Explorer |
| `Space T R` | Run all tests |
| `Space T F` | Run tests in current file |

---

## .NET / C# *(only when a solution is open)*

| Key | Action |
|-----|--------|
| `Space N B` | Build solution |
| `Space N R` | Rebuild solution |
| `Space N S` | Open solution |

---

## AI / Chat

| Key | Action |
|-----|--------|
| `Space C C` | Toggle auxiliary bar (Copilot / secondary sidebar) |
| `Space C F` | Open VSCode chat sidebar |
| `Ctrl+1` | Return focus to editor from chat panel |

> **Note:** `Ctrl+H` and other Space-leader bindings are intercepted by the Claude Code webview and do not work from inside it. `Ctrl+1` is handled at the VSCode window level and always works.
> Claude Code preferred location is set to `"panel"` in `settings.json`.

---

## Layout & View

| Key | Action |
|-----|--------|
| `Space Z` | Toggle Zen mode |
| `Space O` | Focus Outline panel |
| `Space U H` | Increase view width |
| `Space U Shift+H` | Decrease view width |
| `Space U V` | Increase view height |
| `Space U Shift+V` | Decrease view height |
| `Space U M` | Maximize editor *(Normal mode, editor focus)* |
| `Space U M` | Maximize/restore panel *(panel focus, non-terminal)* |

---

## Quick Input / Code-Action Menu

| Key | Action |
|-----|--------|
| `Tab` | Next item in quick-pick / next code action |
| `Shift+Tab` | Previous code action |

---

## Vim Extras

| Key | Mode | Action |
|-----|------|--------|
| `Escape` | Normal | Clear search highlights (`:nohl`) |
| `Ctrl+Q` | Normal | Enter Visual Block mode — replaces `Ctrl+V` |
| `P` (lowercase) | Visual | Paste without clobbering register |
| `ů` | Normal / Visual / Op-pending | First non-blank of line (`^`) |
| `§` | Normal / Visual / Op-pending | End of line (`$`) |
| `(` | Normal | Jump to `{` (block start) |
| `)` | Normal | Jump to `}` (block end) |

### Czech number-row digit remapping *(Normal mode)*

| Bare key | Digit |
|----------|-------|
| `+` | `1` |
| `ě` | `2` |
| `š` | `3` |
| `č` | `4` |
| `ř` | `5` |
| `ž` | `6` |
| `ý` | `7` |
| `á` | `8` |
| `í` | `9` |
| `é` | `0` (also the `0` line-start motion) |

---

## Vim — Motion & Navigation

> All motions compose with operators (`d`, `y`, `c`, `v`, …).

### Character & word

| Key | Action |
|-----|--------|
| `h` `j` `k` `l` | Left / down / up / right |
| `w` / `W` | Next word start (word / WORD) |
| `b` / `B` | Previous word start |
| `e` / `E` | Next word end |
| `ge` / `gE` | Previous word end |

### Line

| Key | Action |
|-----|--------|
| `0` *(bare `é`)* | Start of line (column 0) |
| `ů` | First non-blank of line (`^`) |
| `§` | End of line (`$`) |
| `g_` | Last non-blank of line |
| `_` | First non-blank (also used as indent in Visual — see Editor Actions) |

### Screen / paragraph / file

| Key | Action |
|-----|--------|
| `H` / `M` / `L` | Top / middle / bottom of screen |
| `{` / `}` | Previous / next empty line (paragraph boundary) |
| `gg` | First line of file |
| `G` | Last line of file |
| `{n}G` | Go to line *n* |
| `Ctrl+D` / `Ctrl+U` | Scroll half-page down / up |
| `Ctrl+F` / `Ctrl+B` | Scroll full page forward / back |
| `zz` | Center current line on screen |
| `zt` / `zb` | Current line to top / bottom |

### Find on line

| Key | Action |
|-----|--------|
| `f{c}` | Jump forward to character *c* |
| `F{c}` | Jump backward to character *c* |
| `t{c}` / `T{c}` | Jump to just before *c* (forward / backward) |
| `;` / `,` | Repeat last `f/F/t/T` forward / backward |

### Matching pairs

| Key | Action |
|-----|--------|
| `%` | Jump to matching bracket / paren / brace |
| `(` | Jump to `{` *(remapped — see Vim Extras)* |
| `)` | Jump to `}` *(remapped — see Vim Extras)* |

---

## Vim — Operators & Text Objects

> Pattern: `{operator}{motion}` or `{operator}{text-object}`.  
> Double the operator to act on the whole line: `dd`, `yy`, `cc`, `>>`, `<<`.

### Operators

| Key | Action |
|-----|--------|
| `d` | Delete (cut) |
| `y` | Yank (copy) |
| `c` | Change (delete + enter Insert) |
| `>` / `<` | Indent / outdent |
| `=` | Auto-indent |
| `g~` / `gu` / `gU` | Toggle / lower / upper case |
| `!` | Filter through external program |

### Useful shorthands

| Key | Equivalent | Action |
|-----|-----------|--------|
| `x` | `dl` | Delete character under cursor |
| `X` | `dh` | Delete character before cursor |
| `D` | `d§` | Delete to end of line |
| `C` | `c§` | Change to end of line |
| `Y` | `yy` | Yank whole line (VSCode-Vim behaviour) |
| `s` | `cl` | Substitute character |
| `S` | `cc` | Substitute whole line |
| `r{c}` | — | Replace character under cursor with *c* |
| `~` | — | Toggle case of character under cursor |

### Text objects *(used after `d`, `y`, `c`, `v`, …)*

| Key | Selects |
|-----|---------|
| `iw` / `aw` | Inner word / word + surrounding space |
| `iW` / `aW` | Inner WORD / WORD + space |
| `is` / `as` | Inner sentence / sentence + space |
| `ip` / `ap` | Inner paragraph / paragraph + blank line |
| `i"` / `a"` | Inside / around double quotes |
| `i'` / `a'` | Inside / around single quotes |
| `` i` `` / `` a` `` | Inside / around backticks |
| `i(` / `a(` | Inside / around `()` |
| `i[` / `a[` | Inside / around `[]` |
| `i{` / `a{` | Inside / around `{}` |
| `i<` / `a<` | Inside / around `<>` |
| `it` / `at` | Inside / around XML/HTML tag |

### Surround *(vim-surround enabled)*

| Key | Action |
|-----|--------|
| `ys{motion}{c}` | Add surround *c* around motion (e.g. `ysiw"` wraps word in `"`) |
| `yss{c}` | Add surround around entire line |
| `cs{old}{new}` | Change surrounding *old* to *new* (e.g. `cs'"` changes `'` to `"`) |
| `ds{c}` | Delete surrounding *c* (e.g. `ds(` removes parentheses) |
| `S{c}` | Surround Visual selection with *c* |

---

## Vim — Insert Mode

| Key | Action |
|-----|--------|
| `i` / `I` | Insert before cursor / before first non-blank |
| `a` / `A` | Append after cursor / after end of line |
| `o` / `O` | Open new line below / above and enter Insert |
| `gi` | Re-enter Insert at last insert position |
| `Ctrl+W` | Delete word before cursor |
| `Ctrl+U` | Delete to start of line |
| `Ctrl+R {reg}` | Paste from register *reg* |
| `Ctrl+O {cmd}` | Execute one Normal command then return to Insert |
| `Escape` / `Ctrl+[` | Return to Normal mode |

---

## Vim — Visual Mode

| Key | Action |
|-----|--------|
| `v` | Start character-wise Visual |
| `V` | Start line-wise Visual |
| `Ctrl+Q` | Start Visual Block *(remapped from `Ctrl+V` — see Vim Extras)* |
| `gv` | Re-select last Visual selection |
| `o` | Move cursor to other end of selection |
| `p` | Paste over selection without clobbering register *(remapped — see Vim Extras)* |
| `u` / `U` | Lowercase / uppercase selection |
| `>` / `<` | Indent / outdent selection (stays in Visual) |
| `?` | Outdent *(remapped — see Editor Actions)* |
| `_` | Indent *(remapped — see Editor Actions)* |
| `J` | Move selected lines down *(VisualLine — see Editor Actions)* |
| `K` | Move selected lines up *(VisualLine — see Editor Actions)* |

---

## Vim — Search & Replace

### Search navigation

| Key | Action |
|-----|--------|
| `/{pattern}` | Search forward |
| `?{pattern}` | Search backward |
| `n` / `N` | Next / previous match |
| `*` / `#` | Search forward / backward for word under cursor |
| `g*` / `g#` | Same, but partial match |
| `Escape` | Clear highlights *(remapped — see Vim Extras)* |

### Substitution *(command-line)*

| Command | Action |
|---------|--------|
| `:s/old/new/` | Replace first match on current line |
| `:s/old/new/g` | Replace all matches on current line |
| `:%s/old/new/g` | Replace all matches in file |
| `:%s/old/new/gc` | Same, with confirmation prompt |
| `:'<,'>s/old/new/g` | Replace in Visual selection |

> Tip: `\v` at the start of a pattern enables "very magic" mode (standard regex without escaping `()`, `+`, etc.).

---

## Vim — Marks & Jumps

| Key | Action |
|-----|--------|
| `m{a-z}` | Set local mark *a–z* |
| `m{A-Z}` | Set global mark *A–Z* (cross-file) |
| `` `{mark} `` | Jump to exact position of mark |
| `'{mark}` | Jump to first non-blank of mark's line |
| `` `. `` | Jump to position of last change |
| `` `[ `` / `` `] `` | Start / end of last yank or change |
| `` `< `` / `` `> `` | Start / end of last Visual selection |
| `Ctrl+O` / `Ctrl+I` | Jump backward / forward in jump list |
| `g;` / `g,` | Older / newer position in change list |

---

## Vim — Folds

> VSCode-Vim maps fold keys to VSCode's native fold commands. Native Vim fold creation (`zf`, fold methods) is **not** supported.

| Key | Action |
|-----|--------|
| `za` | Toggle fold under cursor |
| `zo` / `zO` | Open fold / open all nested folds |
| `zc` / `zC` | Close fold / close all nested folds |
| `zR` | Open all folds in file |
| `zM` | Close all folds in file |

---

## Miscellaneous

| Key | Action |
|-----|--------|
| `Shift+Alt+F12` | Markdown: find all file references |
| `Ctrl+Alt+Win+B` | LaTeX Workshop: run recipe |