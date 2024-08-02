# General

- [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management
- [noice.nvim](https://github.com/folke/noice.nvim) to change the Neovim interface
- LSP configuration for the languages I use
- [blink.cmp](https://github.com/saghen/blink.cmp) for completion
- No tree plugin, I use [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) to navigate and [oil.nvim](https://github.com/stevearc/oil.nvim) to move/rename/delete files
- Base16 color scheme inherited from my NixOS configuration

# Notable changes to default neovim behavior

## Virtual edit enabled

Allows the cursor to move freely, even where there’s no text.

## Text objects

This config uses [unified-text-objects](https://github.com/vE5li/unified-text-objects.nvim) to provide more consistent and powerful text objects.

## Yank, delete, and change don't move the cursor

The yank (`y`), delete (`d`) and change (`c`) operators doesn't change the cursor position.
See [YankAssassin.nvim](https://github.com/svban/YankAssassin.nvim) and [delete-assassin.nvim](https://github.com/vE5li/delete-assassin.nvim) for more information.

## Put as an operator

Paste works like an operator (e.g. `pp`, `Pp`, `pi"`, `Pi"`) and doesn’t move the cursor.
- `p` operator for pasting and yanking the deleted text
- `P` operator for pasting without yanking the deleted text

## Custom status line with Lualine

Clean and pretty with a focus on displaying the current mode.
It also has a [`jujutsu`](https://github.com/jj-vcs/jj) integration.
