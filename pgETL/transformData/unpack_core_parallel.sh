#!/bin/bash

process_file() {

    TMPDIR=$1
    DESTDIR=$2
    
    DESTFULLTEXT=$DESTDIR"fulltext/"
    DESTDOCS=$DESTDIR"docs/"
    
    echo "unpack"
    PROVIDER=$(basename -- "${FILE%.*.*}")
    $TMP_PROVIDER=$TMPDIR$PROVIDER
    echo "$PROVIDER start"
    echo $TMP_PROVIDER
    mkdir -p $TMP_PROVIDER
    tar xf $FILE -C $TMP_PROVIDER

    # Temp Full Text location
    TMP_FULLTEXT=$TMP_PROVIDER"fulltext"
    
    # Locations for final output
    DOCS=$DESTDOCS"provider=$PROVIDER"
    
    echo "make folders"
    mkdir -p $DOCS
    mkdir -p $TMP_FULLTEXT
    
    echo "parse json"

    for JSONFILE in $TMPDIR*/*/*.json;
    do
        # Add provider ID field and remove fullText to create and save compacted json.
        jq --argjson provider "$(jo provider_id="$PROVIDER")" '. += $provider' < $JSONFILE |
        jq -c 'del(.fullText)' >> $DOCS/documents_"$PROVIDER".jsonl

        # Create separate json with core_id and fullText for relevant ids.
        jq 'with_entries(select(.key | in({"coreId":1,"fullText":1})))' $JSONFILE |
        jq -c 'select(.fullText != null)' >> $TMP_FULLTEXT/fulltext_"$PROVIDER".jsonl    
    done

    tar czf $DESTFULLTEXT/fulltext_"$PROVIDER".gz -C $TMP_FULLTEXT .
    rm -r $TMP_PROVIDER
    #rm $FILE
    echo "$PROVIDER finish"
}

#ROOTPATH=/Users/josepherlanger/Projects/mcc/pgETL/local/data_samples/
ROOT_PATH=/var/data/core/test/

SOURCEDIR=$ROOTPATH"core_output/"
TMPDIR=$ROOTPATH"core_tmp/"
DESTDIR=$ROOTPATH"output/"

DESTFULLTEXT=$DESTDIR"fulltext/"
DESTDOCS=$DESTDIR"docs/"

mkdir -p $DESTDIR
mkdir -p $DESTFULLTEXT
mkdir -p $DESTDOCS
mkdir -p $TMPDIR

max_num_processes=1000
limited_factor=1
num_processes=$((max_num_processes/limited_factor))

for FILE in `ls -1 $SOURCEDIR*.tar.xz`;
do
  ((i=i%num_processes)); ((i++==0)) && wait
  process_file "$TMPDIR" "$DESTDIR" &
done

tar czf $DESTDIR/core_fulltext.gz -C $DESTFULLTEXT .
rm -r $DESTFULLTEXT
