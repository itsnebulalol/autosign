# AutoSign

Automatically signs binaries when installed with dpkg/apt.

# How does this work?

This hijacks dpkg to run a script before running the real dpkg. The script resigns the deb, and can be found in `/usr/bin/resign_deb.sh`.

# Where can I get this?

You can get it from [my repo](https://apt.itsnebula.net) or [GitHub releases](https://github.com/itsnebulalol/autosign/releases).

You can also build yourself by using the `make` command.

# Credits

- [woofy](https://github.com/netsirkl64) for the hijacking dpkg idea (and dpkg.fake)
- [Tom](https://github.com/guacaplushy) for the base of the resign_deb.sh script.
