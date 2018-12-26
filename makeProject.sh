#!/bin/bash

display_usage() { 
	echo "This script must be run with sthe project title has argument " 
	echo -e "\nUsage:\n$0 <project name> \n" 
} 

# if less than two arguments supplied, display usage 
if [  $# -le 0 ] 
then 
	display_usage
	exit 1
fi

if [ -d "$1" ]; then
  echo -e "\nDestination directory must NOT exist !\n"
  exit 2
fi

mkdir $1

cd $1

# Setup Spring
SPRING_STYLES="-d style=web"
SPRING_STYLES="${SPRING_STYLES} -d style=jpa -d style=mysql"
SPRING_STYLES="${SPRING_STYLES} -d style=lombok"
# comment to suppress security modules
SPRING_STYLES="${SPRING_STYLES} -d style=security"

echo "SPRING_STYLES=${SPRING_STYLES}"


curl https://start.spring.io/starter.tgz ${SPRING_STYLES} \
		-d groupId=lu.plezy -d artifactId=$1 \
		-d name=$1 | tar -xzvf -

# Default mysql Database
cat <<'EOF' >src/main/resources/application.properties
spring.jpa.hibernate.ddl-auto=create
spring.datasource.url=jdbc:mysql://localhost:3306/db_example
spring.datasource.username=springuser
spring.datasource.password=ThePassword
EOF

# Setup Angular
ng new client --directory=src/main/client --routing=true --style=css --skip-git=true --skip-install=true

cat <<'EOF' >/tmp/addPlugins.xml
    <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>exec-maven-plugin</artifactId>
        <version>1.5.0</version>
        <executions>
            <execution>
                <id>exec-npm-install</id>
                <phase>generate-sources</phase>
                <configuration>
                    <workingDirectory>${project.basedir}/src/main/client</workingDirectory>
                    <executable>npm</executable>
                    <arguments>
                        <argument>install</argument>
                    </arguments>
                </configuration>
                <goals>
                    <goal>exec</goal>
                </goals>
            </execution>
            <execution>
                <id>exec-npm-ng-build</id>
                <phase>generate-sources</phase>
                <configuration>
                    <workingDirectory>${project.basedir}/src/main/client</workingDirectory>
                    <executable>ng</executable>
                    <arguments>
                        <argument>build</argument>
                        <argument>--base-href=/</argument>
                    </arguments>
                </configuration>
                <goals>
                    <goal>exec</goal>
                </goals>
            </execution>
        </executions>
    </plugin>
EOF

# sed -e '/<\/plugins>/r /tmp/addPlugins.xml' -e //N pom.xml | xmllint --format -
sed -i -e '/<\/plugins>/r /tmp/addPlugins.xml' -e //N pom.xml
xmllint --format --output pom.xml pom.xml

# sed -e 's/"outputPath":.*/"outputPath": "..\/..\/..\/target\/static",/' ./src/main/client/angular.json
sed -i -e 's/"outputPath":.*/"outputPath": "..\/..\/..\/target\/classes\/static",/' ./src/main/client/angular.json

git init
git add .

