#!/bin/bash

CLASSPATH=lib/BuildCorpora.jar:lib/Helper.jar:lib/commons-collections4-4.0-alpha1.jar
#options are: stripped (AMR), full (AMR), and deAnonymize (NL)
TYPE=$1
INPUT=$2
java -cp ${CLASSPATH} uk.ac.ed.gen.util.AmrUtils ${TYPE} "${INPUT}"

