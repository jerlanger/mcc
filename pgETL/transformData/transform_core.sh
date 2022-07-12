#!/bin/bash

SOURCEDIR=/Users/josepherlanger/Projects/mcc/pgETL/local/data_samples/core_sample/
DESTDIR=/Users/josepherlanger/Projects/mcc/pgETL/local/data_samples/core_transform/

jq 'with_entries(select(.key | in({"coreId":1,"fullText":1})))' $SOURCEDIR/sample_copy.json > $DESTDIR/test_fulltext_only.json

jq 'del(.fullText)' $SOURCEDIR/sample_copy.json > $DESTDIR/test_nofulltext.json