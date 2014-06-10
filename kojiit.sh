# Abuses scratch builds to build armv6hl packages for Raspberry Pi
#
# Usage:
#
# Build default uboot branch into release 20:
#     git clone git@github.com:fedora-rpi/uboot-tools.git
#     kojiit.sh uboot-tools
#
# Build rawhide kernel
#     git clone --branch master git@github.com:fedora-rpi/kernel.git kernel-rawhide
#     kojiit.sh kernel-rawhide devel

set -e

A=armv6hl
T=f21

C="$2"
[ "$C" ] || C=20
mkdir -p rpms/$C

if [ "$1" ]
then
	F=$(fedpkg --dist $T --path $1 srpm |awk '/Wrote:/ {print $NF}')
	[ "$N" ] || N=$(koji build --nowait --noprogress --scratch --arch-override=$A $T $F |
		awk '/Created task:/ {print $NF}')
	[ "$N" ]
	koji watch-task $N
	koji taskinfo -r -v $N |
		sed -n 's|.*/mnt/koji/\(.*\/tasks\/\)|https://kojipkgs.fedoraproject.org/\1|p' |
		xargs wget -c --directory-prefix=rpms/$C/$N
fi

createrepo rpms/$C
rsync -avr --delete rpms/. fedorapeople.org:public_html/fedora-rpi/.
