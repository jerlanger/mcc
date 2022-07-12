#!/bin/bash

SOURCEDIR=/Users/josepherlanger/Projects/mcc/pgETL/local/data_samples/core_filestruct/

for FOLDER in `ls -1 $SOURCEDIR`;
do
        PROVIDER="_"$FOLDER
        echo $PROVIDER
        for JSONFILE in $SOURCEDIR/$FOLDER/*/*.json;
        do
          #jq '.provider += $PROVIDER' $JSONFILE
          #jq --argjson newval "$( jo new_key="$PROVIDER" )" '.array[] += $newval' <<< $JSONFILE
          jq --argjson newval "$( jo new_key="$PROVIDER" )" '.provider[$newval]' <<< $JSONFILE
          #jq --arg v "$PROVIDER" '.provider[$v]' $JSONFILE
          #jq "." $JSONFILE
        done
done


