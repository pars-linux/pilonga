Private Scripts and Commands 

diropts  	-m0755  	Sets the options used when running dodir  	diropts -m0750
dobin 	N/A 	Installs the specified binaries into DESTTREE/bin 	dobin wmacpi
docinto 	"" 	Sets the relative subdir used by dodoc 	docinto examples
dodir 	N/A 	Creates a directory, handling ${D} transparently 	dodir /usr/lib/newpackage
dodoc 	N/A 	Installs the specified files into the package's documentation directory (/usr/share/doc/${PF}/DOCDESTTREE) (see docinto) 	dodoc README *.txt
doexe 	N/A 	Installs the specified files with mode EXEOPTIONS (see exeopts) into PATH defined by EXEINTO (see exeinto). 	doexe ${FILESDIR}/quake3
dohard 	N/A 	Creates a hard link, handling ${D} transparently 	dohard ls /bin/dir
dohtml 	N/A 	Installs the specified files and directories into /usr/share/doc/${PF}/html 	dohtml -r doc/html/*
doinfo 	N/A 	Installs the specified files into /usr/share/info, then compresses them with gzip 	doinfo doc/*.info
doins 	N/A 	Installs the specified files with mode INSOPTIONS (see insopts) into INSDESTTREE (see insinto) 	doins *.png icon.xpm
dolib 	N/A 	Installs the specified libraries into DESTTREE/lib with mode 0644 	dolib *.a *.so
dolib.a 	N/A 	Installs the specified libraries into DESTTREE/lib with mode 0644 	dolib.a *.a
dolib.so 	N/A 	Installs the specified libraries into DESTTREE/lib with mode 0755 	dolib.so *.so
doman 	N/A 	Installs the specified files into /usr/share/man/manX, according to the suffix of the file (file.1 will go into man1) 	doman *.1 *.5
dosbin 	N/A 	Installs the files into DESTTREE/sbin, making sure they are executable 	dosbin ksymoops
dosym 	N/A 	Creates a symlink, handles ${D} transparently 	dosym gzip /bin/zcat
emake 	N/A 	Runs make with MAKEOPTS. Some packages cannot be made in parallel; use emake -j1 instead. If you need to pass any extra arguments to make, simply append them onto the emake command. Users can set the EXTRA_EMAKE environment variable to pass extra flags to emake. 	emake
exeinto 	/ 	Sets the root (EXEDESTTREE) for the doexe command 	exeinto /usr/lib/${PN}
exeopts 	-m0755 	Sets the options used when running doexe 	exeopts -m1770
fowners 	N/A 	Applies the specified ownership to the specified file via the chown command, handles ${D} transparently 	fowners root:root /sbin/functions.sh
fperms 	N/A 	Applies the specified permissions to the specified file via the chmod command, handles ${D} transparently 	fperms 700 /var/consoles
insinto 	/usr 	Sets the root (INSDESTTREE) for the doins command 	insinto /usr/include
insopts 	-m0644 	Sets the options used when running doins 	insopts -m0444
into 	/usr 	Sets the target prefix (DESTTREE) for all the 'do' commands (like dobin, dolib, dolib.a, dolib.so, domo, dosbin) 	into /
libopts 	-m0644 	Sets the options used when running dolib 	libopts -m0555
newbin 	N/A 	Wrapper around dobin which installs the specified binary transparently renaming to the second argument 	newbin ${FILESDIR}/vmware.sh vmware
newdoc 	N/A 	Wrapper around dodoc which installs the specified file transparently renaming to the second argument 	newdoc README README.opengl
newexe 	N/A 	Wrapper around doexe which installs the specified file transparently renaming to the second argument 	newexe ${FILESDIR}/xinetd.rc xinetd
newins 	N/A 	Wrapper around doins which installs the specified file transparently renaming to the second argument 	newins ntp.conf.example ntp.conf
newman 	N/A 	Wrapper around doman which installs the specified file transparently renaming to the second argument 	newman xboing.man xboing.6
newsbin 	N/A 	Wrapper around dosbin which installs the specified file transparently renaming to the second argument 	newsbin strings strings-static
prepall 	N/A 	Runs prepallman, prepallinfo and prepallstrip. Also ensures all libraries in /opt/*/lib, /lib, /usr/lib and /usr/X11R6/lib are executable. also moves any stray aclocal macros into /usr/share/aclocal 	prepall
prepalldocs 	N/A 	Recursively gzips all doc files in /usr/share/doc, transparently fixing up any symlink paths 	prepalldocs
prepallinfo 	N/A 	Recursively gzips all info files in /usr/share/info 	prepallinfo
prepallman 	N/A 	Recursively gzips all man pages in /opt/*/man/*, /usr/share/man/*, /usr/local/man/*, /usr/X11R6/share/man/* and transparently fixes up any symlink paths 	prepallman
