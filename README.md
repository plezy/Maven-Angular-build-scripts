## Installation des dépendances
```
sudo apt-get install -y node curl git maven
sudo npm install -g @angular/cli
```

## Configuration d'un proxy

Dans le cas où un proxy est utilisö, voici les commandes ä utiliser
pour le configurer.

```
git config --global http.proxy http://<proxy host>:<proxy port>
git config --global https.proxy http://<proxy host>:<proxy port>

npm config set proxy http://<proxy host>:<proxy port>
npm config set https-proxy http://<proxy host>:<proxy port>

echo "proxy=<proxy host>:<proxy port>" >~/.curlrc

cat <<EOF >~/.m2/settings.xml
<settings>
  <proxies>
   <proxy>
    <id>http proxy</id>
    <active>true</active>
    <protocol>http</protocol>
    <host>your proxy host</host>
    <port>proxy port</port>
    <nonProxyHosts>localhost|127.0.0.1</nonProxyHosts>
   </proxy>
   <proxy>
    <id>https proxy</id>
    <active>true</active>
    <protocol>https</protocol>
    <host>your proxy host</host>
    <port>proxy port</port>
    <nonProxyHosts>localhost|127.0.0.1</nonProxyHosts>
   </proxy>
  </proxies>
</settings>
EOF
```
