#! /bin/bash
FILE_PATH=/opt
if [ $PWD != ${FILE_PATH} ];then
	cd ${FILE_PATH}
fi
i=1
ls | while read f
	do
		cp $f `echo $f | sed  "s/\([^.]*\)\(.*\)/$i\2/"`
		let "i += 1"
		#i=$[ $i + 1 ]
		#i=$(($i+1))
	done
