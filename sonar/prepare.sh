#!/bin/bash

###
#
# bash script for downloading the project, fixing wrong paths, dependencies, names etc.
# + building with Maven and deploying on Tomcat 9
#
###

### variables
##################################################

G_NAME="Geocit134"
G_REPOSITORY="https://github.com/wladOSnull/Geocit134"

G_SERVER_IP="localhost"
G_DB_IP="localhost"

G_DB_USERNAME="geocitizen"
G_DB_PASSWORD="weakpass"

G_EMAIL_ADDRESS="???"
G_EMAIL_PASSWORD="???"
G_EMAIL_SMTP="smtp.ukr.net"

### the project
##################################################

### removing
echo -e "##################################################\nRemoving the old project\n##################################################\n"
rm -rf $G_NAME

### getting
echo -e "##################################################\nCloning the project again\n##################################################\n"
git clone $G_REPOSITORY

### fixing dependencies and packets in 'pom.xml'
##################################################

echo -e "\n##################################################\nSmall errors fixing\n##################################################\n"

### 'javax' missing
sed -i "s/>servlet-api/>javax.servlet-api/g" ${G_NAME}/"pom.xml"

### https for 2 repo
sed -i -E "s/(http:\/\/repo.spring)/https:\/\/repo.spring/g" ${G_NAME}/"pom.xml"

### redundant nexus repos
sed -i "/<distributionManagement>/,/<\/distributionManagement>/d" ${G_NAME}/pom.xml

### missing version of maven war plugin
printf '%s\n' '0?<artifactId>maven-war-plugin<\/artifactId>?a' '                <version>3.3.2</version>' . x | ex ${G_NAME}/"pom.xml"

### missing 'validator' attribute
sed -i -E ':a;N;$!ba; s/org.hibernate/org.hibernate.validator/2' ${G_NAME}/"pom.xml"

### remove duplicates
##################################################

echo -e "##################################################\nDuplicates removing\n##################################################\n"

### function for deleting xml block with specified string
function XML_OBJECT_REMOVE()
{
    ### $1 - UP TO
    ### $2 - DOWN TO
    echo -e "${1} ---------- ${2}\n"
    
    ### $3 - line pointer
    POINTER=$3

    ### delete duplicate TOP
    EDGE=true
    while [ "$EDGE" = true ]; do
        
        if ! [[ "$DUPLICATE_LINE" == "${1}" ]]; then
            sed -i "${POINTER}d" ${G_NAME}/pom.xml
        
            ((POINTER--))
            DUPLICATE_LINE=`sed -n "${POINTER}p" < ${G_NAME}/pom.xml`
            DUPLICATE_LINE=`echo $DUPLICATE_LINE | sed 's/ *$//g'`
        else
            EDGE=false
            sed -i "${POINTER}d" ${G_NAME}/pom.xml
        fi
        
    done

    ### delete duplicate DOWN
    EDGE=true
    while [ "$EDGE" = true ]; do
        
        if ! [[ "$DUPLICATE_LINE" == "${2}" ]]; then
            sed -i "${POINTER}d" ${G_NAME}/pom.xml

            DUPLICATE_LINE=`sed -n "${POINTER}p" < ${G_NAME}/pom.xml`
            DUPLICATE_LINE=`echo $DUPLICATE_LINE | sed 's/ *$//g'`
        else
            EDGE=false
            sed -i "${POINTER}d" ${G_NAME}/pom.xml
        fi

    done
}

### get the duplicate of maven war plugin
DUPLICATE_NUMBER=`grep -n -m1 'maven-war' ${G_NAME}/pom.xml | cut -f1 -d:`
DUPLICATE_LINE=`sed -n "${DUPLICATE_NUMBER}p" < ${G_NAME}/pom.xml`
DUPLICATE_LINE=`echo $DUPLICATE_LINE | sed 's/ *$//g'`
TOP="<plugin>"
DOWN="</plugin>"

### remove it
XML_OBJECT_REMOVE $TOP $DOWN $DUPLICATE_NUMBER

### get the duplicate of postgresql plugin
DUPLICATE_NUMBER=`grep -n "org.postgresql" ${G_NAME}/pom.xml | sed -n 2p | cut -f1 -d:`
DUPLICATE_LINE=`sed -n "${DUPLICATE_NUMBER}p" < ${G_NAME}/pom.xml`
DUPLICATE_LINE=`echo $DUPLICATE_LINE | sed 's/ *$//g'`
TOP="<dependency>"
DOWN="</dependency>"

### remove it
XML_OBJECT_REMOVE $TOP $DOWN $DUPLICATE_NUMBER

### fixing front-end
##################################################

echo -e "##################################################\nFront-end fixing\n##################################################\n"

### wrong path to favicon.ico
sed -i 's/\/src\/assets/.\/static/g' ${G_NAME}/src/main/webapp/"index.html"

### wrong back-end in minificated .js files
find ./${G_NAME}/src/main/webapp/static/js/ -type f -exec sed -i "s/localhost:8080/${G_SERVER_IP}:80/g" {} +

### fixing properties of the project deployment
##################################################

sed -i -E \
            "s/(front.url=http:\/\/localhost:8080)/front.url=http:\/\/${G_SERVER_IP}:80/g; \
            s/(front-end.url=http:\/\/localhost:8080)/front-end.url=http:\/\/${G_SERVER_IP}:80/g; \

            s/(db.url=jdbc:postgresql:\/\/localhost)/db.url=jdbc:postgresql:\/\/${G_DB_IP}/g;
            s/(db.username=postgres)/db.username=${G_DB_USERNAME}/g;
            s/(db.password=postgres)/db.password=${G_DB_PASSWORD}/g;

            s/(url=jdbc:postgresql:\/\/35.204.28.238)/url=jdbc:postgresql:\/\/${G_DB_IP}/g;
            s/(username=postgres)/username=${G_DB_USERNAME}/g;
            s/(password=postgres)/password=${G_DB_PASSWORD}/g;

            s/(referenceUrl=jdbc:postgresql:\/\/35.204.28.238)/referenceUrl=jdbc:postgresql:\/\/${G_DB_IP}/g;

	        s/(mail.smtps.host=smtp.gmail.com)/mail.smtps.host=${G_EMAIL_SMTP}/g;
            s/(email.username=ssgeocitizen@gmail.com)/email.username=${G_EMAIL_ADDRESS}/g;
            s/(email.password=softserve)/email.password=${G_EMAIL_PASSWORD}/g;" ${G_NAME}/src/main/resources/application.properties

### fixing for test
##################################################

echo -e "##################################################\nTest fixing\n##################################################\n"

### add plugin for 'mvn test'
sed -i '/<plugins>/a \
\
            <plugin>\
              <groupId>org.apache.maven.plugins<\/groupId>\
              <artifactId>maven-surefire-plugin<\/artifactId>\
              <version>3.0.0-M6<\/version>\
              <configuration>\
                  <testFailureIgnore>true</testFailureIgnore>\
              </configuration>\
            <\/plugin>'  ${G_NAME}/"pom.xml"

sed -i '/<plugins>/a \
\
            <plugin>\
                <groupId>org.jacoco<\/groupId>\
                <artifactId>jacoco-maven-plugin<\/artifactId>\
                <version>${jacoco.version}<\/version>\
                <executions>\
                    <execution>\
                        <id>jacoco-initialize<\/id>\
                        <goals>\
                            <goal>prepare-agent<\/goal>\
                        <\/goals>\
                    <\/execution>\
                    <execution>\
                        <id>jacoco-site<\/id>\
                        <phase>package<\/phase>\
                        <goals>\
                            <goal>report<\/goal>\
                        <\/goals>\
                    <\/execution>\
                <\/executions>\
            <\/plugin>' ${G_NAME}/"pom.xml"

echo -e "\n##################################################\nAdd entrypoints for SonarQube\n##################################################\n"

#SONAR_TOKEN="38e2926d14bc0832371ef9477925a681f133a80c"

awk '{print} /<dependencies>/ && !n {print "\
\n\
        <!-- for SonarQube -->\n\
        <dependency>\n\
            <groupId>org.sonarsource.scanner.maven</groupId>\n\
            <artifactId>sonar-maven-plugin</artifactId>\n\
            <version>3.9.1.2184</version>\n\
            <type>pom</type>\n\
        </dependency>\n\
"; n++}' ${G_NAME}/"pom.xml" > ${G_NAME}/"temp.xml"\
&& mv ${G_NAME}/"temp.xml" ${G_NAME}/"pom.xml"

awk '{print} /<\/dependencies>/ && !n {print "\
\n\
        <!-- for SonarQube -->\n\
        <profiles>\n\
                <profile>\n\
                    <id>sonar</id>\n\
                    <activation>\n\
                        <activeByDefault>true</activeByDefault>\n\
                    </activation>\n\
                    <properties>\n\
                        <sonar.host.url>http://localhost:9000</sonar.host.url>\n\
                    <!--    <sonar.login>'"$SONAR_TOKEN"'</sonar.login>  -->\n\
                        <!-- JaCoCo Properties -->\n\
                        <jacoco.version>0.8.8</jacoco.version>\n\
                        <sonar.java.coveragePlugin>jacoco</sonar.java.coveragePlugin>\n\
                        <sonar.dynamicAnalysis>reuseReports</sonar.dynamicAnalysis>\n\
                        <sonar.jacoco.reportPath>${project.basedir}/../target/jacoco.exec</sonar.jacoco.reportPath>\n\
                        <sonar.language>java</sonar.language>\n\
                    </properties>\n\
                </profile>\n\
        </profiles>\n\
"; n++}' ${G_NAME}/"pom.xml" > ${G_NAME}/"temp.xml"\
&& mv ${G_NAME}/"temp.xml" ${G_NAME}/"pom.xml"

echo -e "\n##################################################\nAdd entrypoints for Jacoco\n##################################################\n"

awk '{print} /<dependencies>/ && !n {print "\
\n\
        <!-- JaCoCo Properties -->\n\
        <dependency>\n\
            <groupId>org.jacoco</groupId>\n\
            <artifactId>jacoco-maven-plugin</artifactId>\n\
            <version>0.8.8</version>\n\
        </dependency>\n\
"; n++}' ${G_NAME}/"pom.xml" > ${G_NAME}/"temp.xml"\
&& mv ${G_NAME}/"temp.xml" ${G_NAME}/"pom.xml"

echo -e "\n##################################################\nActivation tests\n##################################################\n"

### enable unit tests in project
find ${G_NAME}/src/test/java/com/softserveinc/geocitizen/ -type f \
-exec sed -i -E "s/(@Ignore)//g;" {} \; \
-print


### project deploying
##################################################

echo -e "##################################################\nThe project building\n##################################################\n"

### project building
(cd ${G_NAME}; mvn install -DskipTests=true)