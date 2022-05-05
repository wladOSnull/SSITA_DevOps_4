#!/bin/bash

G_NAME="Geocit134"

echo -e "\n##################################################\nActivation tests\n##################################################\n"

### enable unit tests in project
find ${G_NAME}/src/test/java/com/softserveinc/geocitizen/ -type f \
-exec sed -i -E "s/(@Ignore)//g;" {} \; \
-print
