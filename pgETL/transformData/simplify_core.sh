#!/bin/bash

SOURCEDIR=/Users/josepherlanger/Projects/mcc/pgETL/local/data_samples/core_sample_2/
DESTDIR=/Users/josepherlanger/Projects/mcc/pgETL/local/data_samples/core_transform_2/

for FOLDER in `ls -1 $SOURCEDIR`;
do
        PROVIDER=$FOLDER
        DOCS=$DESTDIR"docs/provider="$PROVIDER
        FULLTEXT=$DESTDIR"fulltext/provider="$PROVIDER

        mkdir -p $DOCS
        mkdir -p $FULLTEXT

        for JSONFILE in $SOURCEDIR$FOLDER/*/*/*.json;
        do
          # Add provider ID field and remove fullText to create and save reduced json.
          jq --argjson provider "$(jo provider_id="$PROVIDER")" '. += $provider' < $JSONFILE |
          jq 'del(.fullText)' >> $DOCS/docs.jsonl

          # Create separate json with core_id and fullText
          jq 'with_entries(select(.key | in({"coreId":1,"fullText":1})))' $JSONFILE \
          >> $FULLTEXT/fulltext.jsonl
        done
done


