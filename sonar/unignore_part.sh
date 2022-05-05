#!/bin/bash

G_NAME="Geocit134"

echo -e "\n##################################################\nActive tests\n##################################################\n"

### enable unit tests in project
find ${G_NAME}/src/test/java/com/softserveinc/geocitizen/ -type f \
! \( -path '*AuthRestControllerTest*' -o \
    -path '*UsersRestControllerTest*' -o \
    -path '*IssueRepositoryTest*' -o \
    -path '*MessageServiceTest*' \) \
-exec sed -i -E "s/(@Ignore)//g;" {} \; \
-print
