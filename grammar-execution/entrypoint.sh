#!/bin/sh
cd
cd /mnt/tests/$DIRECTORY_PATH

# check that files exist
count=`find $FILES_DIR -type f -name "*.$FILE_EXT" | wc -l`

if [ $count != 0 ]
then 
    mkdir -p results
    touch results/task.log # create
    /opt/src/scripts/grammar-execution $FILES_DIR $FILE_EXT
else
    echo "NO FILES TO TEST"
fi