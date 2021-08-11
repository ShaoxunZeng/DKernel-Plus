# ================ Configuration ====================
DISK_NAME := ubuntu-linux-share
DISK_SIZE := 50G

UBUNTU-ISO := ubuntu-18.04-desktop-amd64.iso
UBUNTU-ISO-LINK := http://old-releases.ubuntu.com/releases/18.04.4/ubuntu-18.04-desktop-amd64.iso

LINUX-KERNEL := ./kernel/vmlinuz-5.13.0
LINUX-INITRD := ./kernel/initrd.img-5.13.0

# **NOTE**: Please change this to correct linux source path (absolute path),
# otherwise LLDB won't print the corresponding source code
LINUX-SOURCE-PATH := /Users/cengshaoxun/Programs/linux-5.13.8

# **NOTE**: Please change this to correct linux build path (absolute path),
# e.g. If you build the kernel in /home/abc/linux-5.13, then set following value to /home/abc/linux-5.13, which would be used for LLDB map source code
# You may find this path as follwing:
# run lldb first, and then type image lookup --verbose --address start_kernel
# see the "CompileUnit" field, which point to build path, 
# which is like /home/zsx/linux-5.13/init/main.c
LINUX-BUILD-PATH := /home/zsx/linux-5.13

LLDB := lldb

GDB := gdb

QEMU := qemu-system-x86_64
# **NOTE**: On linux, change accel=hvf to accel=kvm
QEMU-OPTIONS-ACCELERATION := \
	-machine type=q35,accel=hvf \
	-cpu host \

QEMU-OPTIONS-NORMAL := \
	-m 8G \
	-smp 4 \
	-net nic,model=virtio \
	-net user,hostfwd=tcp::2222-:22 \
	-drive format=raw,file=$(DISK_NAME).raw,if=virtio \

QEMU-OPTIONS-GRAPHIC := \
	-display default,show-cursor=on \
	-vga virtio \

QEMU-OPTIONS-UBUNTU-CDROM := -cdrom ubuntu-18.04-desktop-amd64.iso

QEMU-OPTIONS-UBUNTU-INSTALL := $(QEMU-OPTIONS-NORMAL) $(QEMU-OPTIONS-GRAPHIC) $(QEMU-OPTIONS-UBUNTU-CDROM) $(QEMU-OPTIONS-ACCELERATION)

QEMU-OPTIONS-NO-GRAPHIC := -nographic -serial mon:stdio

QEMU-OPTIONS-LINUX-APPEND := -append "nokaslr root=/dev/vda1 rw console=ttyS0"

QEMU-OPTIONS-LINUX-KERNEL-INITRD := \
	-kernel $(LINUX-KERNEL) \
	-initrd $(LINUX-INITRD) \

QEMU-OPTIONS-LINUX-START := $(QEMU-OPTIONS-NORMAL) $(QEMU-OPTIONS-NO-GRAPHIC) $(QEMU-OPTIONS-LINUX-APPEND) $(QEMU-OPTIONS-LINUX-KERNEL-INITRD)

QEMU-OPTIONS-DEBUG := -s -S

QEMU-OPTIONS-LINUX-DEBUG := $(QEMU-OPTIONS-LINUX-START) $(QEMU-OPTIONS-DEBUG)

# ================ Targets ====================

all: share-disk ubuntu-iso ubuntu-install

share-disk: FORCE
	sudo ./scripts/docker-build-disk.sh $(DISK_NAME) $(DISK_SIZE)

ubuntu-iso: FORCE
	sudo ./scripts/docker-download-ubuntu.sh $(UBUNTU-ISO-LINK)

ubuntu-install: FORCE
	$(QEMU) $(QEMU-OPTIONS-UBUNTU-INSTALL)

# start costomized kernel, after make ubuntu-install, you could use any command just like using ubuntu
linux-start: FORCE
	$(QEMU) $(QEMU-OPTIONS-LINUX-START)

# debug costomized kernel, after make linux-debug, you should open another shell and run make lldb or make gdb
linux-debug: FORCE
	$(QEMU) $(QEMU-OPTIONS-LINUX-DEBUG)

# **NOTE**: You may see the following error when make this target: 
# Error: There is a .lldbinit file in the current directory which is not being read.
# To silence this warning without sourcing in the local .lldbinit, run:
# echo "settings set target.load-cwd-lldbinit true" >> ~/.lldbinit
lldb: FORCE
	@echo -e "**NOTE**: You may see the following error: \n \
	Error: There is a .lldbinit file in the current directory which is not being read. \n \
	To silence this warning without sourcing in the local .lldbinit, run: \n \
	echo \"settings set target.load-cwd-lldbinit true\" >> ~/.lldbinit"
	sudo ./scripts/lldb-conf.sh $(LINUX-BUILD-PATH) $(LINUX-SOURCE-PATH)
	$(LLDB)

gdb:
	sudo ./scripts/lldb-conf.sh $(LINUX-SOURCE-PATH)
	$(GDB) .gdbinit

.PHONY: FORCE
FORCE: