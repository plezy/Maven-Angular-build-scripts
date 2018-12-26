#!/bin/bash
#

# install dependencies
sudo apt-get install -y nodejs

sudo npm install -g @angular/cli
sudo npm install -g typescript

# create an mvn webapp
mvn archetype:generate \
  -DartifactId=j2ee-angular-project \
  -DgroupId=be.plezy.webapps \
  -DarchetypeArtifactId=maven-archetype-webapp \
  -DinteractiveMode=false


cd j2ee-angular-project
cd src/main/
# add Java class source dir
mkdir java

ng new ngapp --skip-git --routing


sed -i 's/"outDir": "dist"/"outdir": "..\/webapp\/ng"' ngapp/.angular-cli.json

cd ../..

cat <<'EOF' > /tmp/mvn-plugins.xml
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.3</version>
        <configuration>
          <excludes>
            <exclude>ngapp/**</exclude>
          </excludes>
        </configuration>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.0.0</version>
        <configuration>
          <excludes>
            <exclude>ngapp/**</exclude>
          </excludes>
        </configuration>
      </plugin>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>exec-maven-plugin</artifactId>
        <version>1.5.0</version>
        <executions>
          <execution>
            <id>exec-npm-install</id>
            <phase>generate-sources</phase>
            <configuration>
              <workingDirectory>${project.basedir}/src/main/ngapp</workingDirectory>
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
              <workingDirectory>${project.basedir}/src/main/ngapp</workingDirectory>
              <executable>ng</executable>
              <arguments>
                <argument>build</argument>
                <argument>--base-href=/ngfirst/ng/</argument>
              </arguments>
            </configuration>
            <goals>
              <goal>exec</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins> 
EOF

ed -i '/<\/build>/e cat /tmp//mvn-plugins.xml' pom.xml

# prepare git

cat <<EOF > .gitignore
target/
dist/
src/main/ngapp/node_modules/
*.class
*.log
*.ctxt
.mtj.tmp/
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
hs_err_pid*
EOF

git init
git add .
git commit -m "Initial j2ee angular web application"



