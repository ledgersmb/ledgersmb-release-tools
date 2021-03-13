
# LedgerSMB release VM

The *single* purpose of this VM is to be the host to create LedgerSMB
releases on. More specifically, it's not designed to create releases of
versions older than 1.5; at the time of writing even 1.5 is long End-of-Life.

There are a few reasons to create a VM instead of a container:

* The release process requires forwarding of both SSH and GnuPG agents,
  which can be achieved with containers, but is proven technology with VMs.
* The VM will be required to run a broad set of services, including
  a PostgreSQL database in order to create schema documentation using
  postgresql-autodoc.
* A planned extension of the release process is to generate Docker images
  and an 'appliance' (virtual machine dedicated to running LedgerSMB).

The requirements in the last two bullets (and especially the last bullet)
makes for an easier solution through VMs.

# Synopsis

```plain

./init
./build
./run
./prep
# <do the release>
rm -rf ./tmp

```

# Design

The VM is built using `virt-builder`, which builds a sparse disk image with a
maximum of 20GB storage. At the time of writing, the actual storage is around
3GB.

The resulting image (and other transient files) are stored in the `tmp/`
subdirectory. To clean up after a release, simply remove the `tmp/` directory.

Static files uploaded to the VM during the VM creation process are in `files/`.
Some files are being dynamically generated or pre-processed before upload. The
actual files uploaded to the VM are in `tmp/` in that case. When the file is
generated from a template, that template is in `tmpls/`.

# Use

@@TODO@@
