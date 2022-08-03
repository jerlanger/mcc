#!/bin/bash

SOURCEDIR=/Users/josepherlanger/Projects/mcc/pgETL/local/data_samples/core_sample_2/
DESTDIR=/Users/josepherlanger/Projects/mcc/pgETL/local/data_samples/core_compressed_output_old/

for FOLDER in `ls -1 $SOURCEDIR`;
do
        PROVIDER=$FOLDER
        DOCS=$DESTDIR"docs/provider="$PROVIDER
        FULLTEXT=$DESTDIR"fulltext/provider="$PROVIDER

        mkdir -p $DOCS
        mkdir -p $FULLTEXT

        for JSONFILE in $SOURCEDIR$FOLDER/*/*/*.json;
        do
          # Add provider ID field and remove fullText to create and save compacted json.
          jq --argjson provider "$(jo provider_id="$PROVIDER")" '. += $provider' < $JSONFILE |
          jq -c 'del(.fullText)' >> $DOCS/documents.jsonl

          # Create separate json with core_id and fullText for relevant ids.
          jq 'with_entries(select(.key | in({"coreId":1,"fullText":1})))' $JSONFILE |
          jq -c 'select(.fullText != null)' >> $FULLTEXT/fulltext.jsonl
        done
done