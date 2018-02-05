#!/bin/bash

# Function Definitions
## Show the help documentation
function usage(){
	helpstr=$(cat <<-EOF

	Usage :: ${0##*/} [-dname PATHTOFOLDER] [-iname NAMEOFIMG] [-vname NAMEOFVOL] 
						[-size SIZE] [-format FORMAT] [-encrypt]

		Take a snapshot of a folder and save it to a disk image (.img)

		REQUIRED INPUT
				-dname		Source folder to take snapshot
				-iname 		Name of the disk image file (*.img)
				-vname 		Name of the volume (name you will see when mounted)

		OPTIONAL INPUT
				-size 		Size of the image, set automatically for read only images.
				-encrypt 	Encrypt the file? Will prompt for password. Requires format. AFPS is selected by default.

	Image from Folder options:
	   -srcfolder <source folder>
	   -[no]spotlight		do (not) create a Spotlight™ index
	   -[no]anyowners		do (not) attempt to preserve owners
	   -[no]skipunreadable		do (not) skip unreadable objects [no]
	   -[no]atomic		do (not) copy to temp location and then rename [yes]
	   -srcowners on|off|any|auto [auto]
	   		on	enable owners on source
	   		off	disable owners on source
	   		any	leave owners state on source unchanged
	   		auto	enable owners if source is a volume
	   -format <image type>			[UDZO]
		UDRO - read-only
		UDCO - compressed (ADC)
		UDZO - compressed
		UDBZ - compressed (bzip2)
		ULFO - compressed (lzfse)
		UFBI - entire device
		IPOD - iPod image
		UDxx - UDIF stub
		UDSB - sparsebundle
		UDSP - sparse
		UDRW - read/write
		UDTO - DVD/CD master
		DC42 - Disk Copy 4.2
		RdWr - NDIF read/write
		Rdxx - NDIF read-only
		ROCo - NDIF compressed
		Rken - NDIF compressed (KenCode)
		UNIV - hybrid image (HFS+/ISO/UDF)
		SPARSEBUNDLE - sparse bundle disk image
		SPARSE - sparse disk image
		UDIF - read/write disk image
		UDTO - DVD/CD master


	EOF)
	echo -e "${helpstr}"
}
## Parse input options
function parse_options(){
	while :; do
		case ${1} in
			-h|--help)
			usage
			exit
			;;
			-encrypt)
				encrypt='-encryption'
			;;
			-dname)
				if [ -n "${2}" ]; then
					sourcedir=${2}
					shift
				else
					echo -e "ERROR -dname requires a non-empty option argument describing the full path to the source folder that will be imaged.\n" >&2
					exit
				fi
			;;
			-vname)
				if [ -n "${2}" ]; then
					volname=${2}
					shift
				else
					echo -e "ERROR -vname requires a non-empty option argument describing name of the volume to be created.\n" >&2
					exit
				fi
			;;			
			-iname)
				if [ -n "${2}" ]; then
					imgname=${2}
					shift
				else
					echo -e "ERROR -iname requires a non-empty option argument describing name of the .img file to be created.\n" >&2
					exit
				fi
			;;
			-format)
				if [ -n "${2}" ]; then
					frmat=${2}
					shift
				else
					echo -e "ERROR -format requires a non-empty option argument describing the format (see -help)\n" >&2
					exit
				fi
			;;												
	        -?*)
	            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
	        ;;
	        *)
	            break
	    esac
	    shift
	done
}

function check_and_set(){
size=''		# must end in g/m/k
frmat='' 	# URDW for read/write
encrypt='' 	# encrypt image?
fs='AFPS'
imgname='happy-disk' # default image name
volname='Happy Disk'
sourcedir='untitled folder'
# check source folder exists
[ ! -d ${sourcedir} ] && echo '⛔️  Source folder ${sourcedir} cannot be found.. exiting' && exit
# define option for size
[ ! -z ${size} ] && size='-size '${size}
# define option for format
[ ! -z ${format} ] && frmat='-format '${frmat}
# define option for filesystem
[ ! -z ${fs} ] && fs='-fs '${fs}
# encrypt folder
[ ! -z ${encrypt} ] && [ -z ${fs} ] && fs='-fs AFPS' && echo -e '⚠️  Filesystem not specified for encrypted folder - writing to AFPS image by default/n'
[ ! -z ${encrypt} ] && encrypt=''${frmat}
}

function snapshot_folder(){
# create disk image from folder
echo hdiutil create ${imgname}.dmg -volname ${volname} -srcfolder ${sourcedir} ${size} ${frmat} ${encrypt} ${fs}
}

#hdiutil resize -size {new size} {imagename}.dmg