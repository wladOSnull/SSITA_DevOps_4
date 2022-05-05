#!/bin/bash

G_NAME="Geocit134"

### project testing + print colorised debug
(\
    cd ${G_NAME}; \
    mvn clean verify sonar:sonar -Dsonar.login=${1} --log-file my_temp.log && \
    cat my_temp.log | grep --color=never '\[INFO\]\|\[ERROR\]\|\[WARNING\]' |  
    GREP_COLOR='01;92' grep --color=always 'BUILD SUCCESS\|$' | 
    GREP_COLOR='01;31' grep --color=always 'BUILD FAILURE\|$' | 
    GREP_COLOR='01;34' grep --color=always 'INFO\|$' | 
    GREP_COLOR='01;31' grep --color=always 'ERROR\|$' |  
    GREP_COLOR='01;93' grep --color=always 'WARNING\|$' && \
    rm my_temp.log \
)
