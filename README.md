# Mailnotify

The `mailnotify` daemon generates pop-up notifications on incoming email
messages by monitoring a log file which records information about incoming
email, in particular the `From:` and `Subject:` email headers. Such an email
log file is usually written by programs like
[fdm](https://github.com/nicm/fdm) or `procmail`.

`mailnotify` can be a useful utility in any X11 (or Wayland) environment
with no complex desktop system. It was originally written for my
[Xmonad](https://xmonad.org) setup.

`mailnotify` relies on a running notification daemon, like
[dunst](https://dunst-project.org/) or similar.

## Usage

Invoking `mailnotify` with no arguments prints the help message about its
usage:

    mailnotify - Pop-up notification on received email.

    Usage: mailnotify [--version] <mail-log> [-i|--icon <icon>] 
                      [-t|--timeout <timeout>]

      Mailnotify generates pop-up notifications about incoming email messages.

    Available options:
      -h,--help                Show this help text
      --version                Show version
      <mail-log>               Mail log file
      -i,--icon <icon>         Icon name or file
                               (default: "mail-unread-symbolic.symbolic")
      -t,--timeout <timeout>   Possible timeouts: `default` use system's default;
                               `infinite` no timeout; N in seconds.
                               (default: Infinite)

For example, assuming that you are using [fdm](https://github.com/nicm/fdm)
to regularly retrieve your email, you could start `mailnotify` from your
`.xinitrc` with a command like this:

    mailnotify ~/.local/log/fdm.log &> ~/.local/log/x11/mailnotify.log &

`mailnotify` would then log any error encountered into `mailnotify.log`,
otherwise it produces no output apart from an initial startup message.

## Install

### Compiled static binaries

Each release contains a compiled static executable of `mailnotify` built on the
most recent Ubuntu LTS platform. That should work on most Linux
distributions. You can download the latest one from
[here](https://github.com/pdobsan/mailnotify/releases/latest). Check the sha256
check sum of the downloaded file. Rename it to `mailnotify`, made it executable
and put somewhere in your search path.

### Building from sources

To build `mailnotify` from source you need a Haskell development environment.
Either your platform package system can provide this or you can use
[ghcup](https://www.haskell.org/ghcup/). Once you have the `ghc` Haskell
compiler and `cabal` etc. installed, follow the steps below.

External dependencies are `libgtk2.0-dev` and `libnotify-dev` on Debian
derivatives,  or `libnotify` and  `gtk2` on Arch derivatives. These must be
installed before `cabal` is invoked.

Clone this repository and invoke `cabal`:

    git clone https://github.com/pdobsan/mailnotify.git
    cd mailnotify
    cabal update
    cabal install

`mailnotify` is known to build with `ghc 8.10.7`, `ghc 9.2.3` and `ghc
9.2.4`.

## License

`mailnotify` is released under the 3-Clause BSD License, see the file
[LICENSE](LICENSE).

