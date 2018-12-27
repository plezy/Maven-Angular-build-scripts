#!/bin/bash
#
#
# depends on npm, ng, curl, git et maven
# to install, run these commands
#
# sudo apt-get install -y node curl git maven
# sudo npm install -g @angular/cli
#
#

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
	<groupId>com.github.eirslett</groupId>
	<artifactId>frontend-maven-plugin</artifactId>
	<version>1.3</version>

	<configuration>
		<nodeVersion>v8.11.3</nodeVersion>
		<npmVersion>6.3.0</npmVersion>
		<workingDirectory>src/main/client/</workingDirectory>
	</configuration>

	<executions>
		<execution>
			<id>install node and npm</id>
 			<goals>
				<goal>install-node-and-npm</goal>
			</goals>
		</execution>

		<execution>
			<id>npm install</id>
			<goals>
				<goal>npm</goal>
			</goals>
		</execution>

		<execution>
			<id>npm run build</id>
			<goals>
				<goal>npm</goal>
			</goals>
			<configuration>
				<arguments>run build</arguments>
			</configuration>
		</execution>

		<execution>
			<id>prod</id>
			<goals>
				<goal>npm</goal>
			</goals>
			<configuration>
				<arguments>run-script build</arguments>
			</configuration>
			<phase>generate-resources</phase>
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


