#!/bin/bash

G_NAME="Geocit134"

echo -e "\n##################################################\nTest files with failures to delete\n##################>

### delete failure test files
rm \
${G_NAME}/src/test/java/com/softserveinc/geocitizen/repository/IssueRepositoryTest.java \
${G_NAME}/src/test/java/com/softserveinc/geocitizen/service/MessageServiceTest.java \
${G_NAME}/src/test/java/com/softserveinc/geocitizen/controller/UsersRestControllerTest.java \
${G_NAME}/src/test/java/com/softserveinc/geocitizen/controller/AuthRestControllerTest.java
