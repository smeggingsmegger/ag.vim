# ack.vim

This plugin is a front for the utility Ag or the  Perl module [App::Ack](http://search.cpan.org/~petdance/ack/ack). Ag/Ack can be used as a replacement for 99% of the uses of _grep_.  This plugin will allow you to run ag / ack from vim, and shows the results in a split window.

## Installation

### Ack

You will need ag / ack, of course, to install it follow the
[manual](http://beyondgrep.com/install/)

### The Plugin

To install it is recommended to use one of the popular package managers for Vim,
rather than installing by drag and drop all required files into your `.vim` folder.

#### Manual (not recommended)

Just
[download](https://github.com/smeggingsmegger/ag.vim/archive/kb-improve-readme.zip) the
plugin and put it in your `~/.vim/`(or `%PROGRAMFILES%/Vim/vimfiles` on windows)

#### Vundle

    Bundle 'smeggingsmegger/ag.vim'

#### NeoBundle

    NeoBundle 'smeggingsmegger/ag.vim'

## Usage

    :Ack [options] {pattern} [{directories}]

Search recursively in {directory} (which defaults to the current directory) for
the {pattern}.

Files containing the search term will be listed in the split window, along with
the line number of the occurrence, once for each occurrence.  [Enter] on a line
in this window will open the file, and place the cursor on the matching line.

Just like where you use :grep, :grepadd, :lgrep, and :lgrepadd, you can use
`:Ack`, `:AckAdd`, `:LAck`, and `:LAckAdd` respectively.
(See `doc/ack.txt`, or install and `:h Ack` for more information.)

For more ack options see
[ack documentation](http://beyondgrep.com/documentation/)

### Keyboard Shortcuts

In the quickfix window, you can use:

    o    to open (same as enter)
    O    to open and close quickfix window
    go   to preview file (open but maintain focus on ag.vim results)
    t    to open in new tab
    T    to open in new tab silently
    h    to open in horizontal split
    H    to open in horizontal split silently
    v    to open in vertical split
    gv   to open in vertical split silently
    q    to close the quickfix window

### Gotchas

Some characters have special meaning, and need to be escaped your search
pattern. For instance, '#'. You have to escape it like this `:Ack '\\\#define
foo'` to search for '#define foo'.
