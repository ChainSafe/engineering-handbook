TEMP_DIR=./temp-docs

rm -r $TEMP_DIR
mkdir $TEMP_DIR

find ./docs -mindepth 1 -type f -print -exec cp {} $TEMP_DIR \;

# TODO
# - Support renaming to lower case