# Experimental External Homebrew Command for GPG Verification

```bash
brew tap domt4/homebrew-gpg
```

And then updates will be picked up in the normal way:

```bash
brew update
```

If the _"experimental"_ label isn't indicative enough of this, __please__ do not treat this command like it is providing you any additional security.

This originated with a project last year that was never quite pushed through to completion for a variety of reasons, but my intention wasn't to abandon the idea & the desire remains to see it become something that ships _with_ Homebrew.

Usage is pretty basic.

```bash
brew fetch-gpg <formula> <URL to GPG signature>
```
such as:

```bash
brew fetch-gpg curl https://curl.haxx.se/download/curl-7.55.1.tar.bz2.asc
```

