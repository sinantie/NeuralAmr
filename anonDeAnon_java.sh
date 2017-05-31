#!/bin/bash

CLASSPATH=lib/BuildCorpora.jar:lib/Helper.jar:lib/commons-collections4-4.0-alpha1.jar:lib/stanford-corenlp-2017-04-14-build.jar
#options are: stripped (AMR-generation), full (AMR-generation), deAnonymize (NL-generation), nerAnonymize (NL-parsing), deAnonymizeAmr (AMR-parsing)
TYPE=$1
INPUT_IS_FILE=$2
INPUT=$3
java -cp ${CLASSPATH} uk.ac.ed.gen.util.AmrUtils ${TYPE} ${INPUT_IS_FILE} "${INPUT}"

