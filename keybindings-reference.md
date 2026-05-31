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

## Miscellaneous

| Key | Action |
|-----|--------|
| `Shift+Alt+F12` | Markdown: find all file references |
| `Ctrl+Alt+Win+B` | LaTeX Workshop: run recipe |