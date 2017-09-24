
# Release tools for LedgerSMB

This repository contains the tools to create LedgerSMB releases, to the
extent that they are releaseversion and releasebranch independent.

# Content

* `vm/`  
  This directory contains the definition of a Debian-based
  minimal VM installation which holds all the prerequisites to
  build a LedgerSMB release.
* `publish/`  
  This directory contains the scripts used to perform the actual
  creation and publication of release artifacts (tarball,
  docker images, api docs, GitHub release, etc).
* `notify/`  
  This directory contains the scripts used to announce the
  release and update various references to the lastest release
  on ledgersmb.org, GitHub.com, wikipedia.org, etc.

