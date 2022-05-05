# Milestone 4

## Terratest

Cool guide to quik start -> [youtube](https://www.youtube.com/watch?v=GLhtnOdSIh0)

Official repo with all Terratest modules -> [gihub](https://github.com/gruntwork-io/terratest/tree/master/modules)

Useful commands for Go:

- to 'retrieve' github.com/modules/... (before first launch of go script)
  
  ```bash
  # must generate go.mod file
  ~ go mod init mod

  # must add list of all requires to go.mod file + generate go.sum file with (in)direct dependencies
  ~ go mod tidy

  # to start go script with tests
  # -v for verbose
  ~ go test -v <name-of-file>.go
  ```

## SonarQube

### SonarQube stuff ...

Official SonarQube repo with packages -> [binaries.sonarqube](https://binaries.sonarsource.com/?prefix=Distribution/sonarqube/)

Additional guide -> [vultr](https://www.vultr.com/docs/install-sonarqube-on-ubuntu-20-04-lts/)

Main guide for SonarQube installation:

  ```bash
  # update system
  ~ sudo apt-get update && sudo apt-get -y upgrade
  
  # java installation
  ~ sudo apt install openjdk-11-jdk

  # add repo for PostgreSQL
  ~ sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
  ~ wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

  # install PostgreSQL
  ~ sudo apt -y install postgresql postgresql-contrib

  # check if postgres service is running&enabled
  
  # set pass for postgres user
  ~ sudo passwd postgres

  ~ sudo -i -u postgres
  ~ createuser sonar

  ~ psql
  ```

  ```sql
  /* in psql cli */
  # ALTER USER sonar WITH ENCRYPTED password '???';
  # CREATE DATABASE sonar OWNER sonar;
  # \q
  ```

  ```bash
  # exit from postgres user
  ~ exit
  
  # download SonarQube - check 'Official SonarQube repo with packages'
  ~ wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip

  # 'installation'
  ~ sudo apt install unzip
  ~ sudo unzip sonarqube-9.4.0.54424.zip -d /opt/
  ~ sudo mv /opt/sonarqube-9.4.0.54424/ /opt/sonarqube
  
  # configure sonar user
  ~ sudo groupadd sonar
  ~ sudo useradd -d /opt/sonarqube -g sonar sonar
  ~ sudo chown sonar:sonar /opt/sonarqube -R

  # change properties of SonarQube
  ~  sudo nano /opt/sonarqube/conf/sonar.properties
  ```

  ```ini
  # in sonar.properties
  sonar.jdbc.username=sonar
  sonar.jdbc.password=sonar_pass
  ...
  sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
  ...
  sonar.web.javaAdditionalOpts=-server
  ```

  ```bash
  # edit main SonarQube script
  ~ sudo nano /opt/sonarqube/bin/linux-x86-64/sonar.sh
  ```

  ```sh
  # in sonar.sh file
  RUN_AS_USER=sonar
  ```

  ```bash
  # create service unit for SonarQube
  ~ sudo nano /etc/systemd/system/sonar.service
  ```

  ```ini
  # in sonar.service file
  [Unit]
  Description=SonarQube service
  After=syslog.target network.target

  [Service]
  Type=forking

  ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
  ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

  User=sonar
  Group=sonar
  Restart=always

  [Install]
  WantedBy=multi-user.target
  ```

  ```bash
  # start + enable SonarQube
  ~ sudo systemctl enable --now sonar.service

  # changes due to usage ElasticSearch by SonarQube
  ~ sudo nano /etc/sysctl.conf
  ```

  ```ini
  # in sysctl.conf file

  ###################################################################
  # for SonarQube due to ElasticSearch
  vm.max_map_count=262144
  fs.file-max=65536
  ulimit -n 65536
  ulimit -u 4096
  ```

  ```bash
  # reboot system after changing sysctl.conf !!!
  ~ sudo reboot now

  # install npm
  ~ sudo apt install npm
  ~ node -v

  # install nvm
  ~ curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
  ~ source ~/.profile

  # list and install specific version of node
  ~ nvm list-remote
  ~ nvm install <version_number OR version_name>

  # unnecessary - alias for specific version
  ~ nvm alias default 16

  # use specific version of node (you can type just 16 instead of 16.x.x)
  ~ nvm use 16
  ~ node -v
  ```

After installation&reboot you an access web interfacec of SonarQube on http://public-ip-of-VM:9000/  
Default credeantials are: *admin, admin*  
Upon first login you have to set new password.

### PostgreSQL configuration for Geocit134

Create user and DBs for Geocit134 tests:

  ```bash
  ~ sudo -i -u postgres psql
  ```

  ```sql
  /* in psql cli */
  # CREATE USER geocitizen WITH PASSWORD 'weakpass';
  # ALTER USER geocitizen CREATEDB;
  # CREATE DATABASE ss_demo_1;
  # CREATE DATABASE ss_demo_1_test;
  # GRANT ALL PRIVILEGES ON DATABASE ss_demo_1 to geocitizen;
  # GRANT ALL PRIVILEGES ON DATABASE ss_demo_1_test to geocitizen;
  ```

Add *md5* auth method for Geocit134 user:

  ```bash
  ~ sudo nano /etc/postgresql/12/main/pg_hba.conf
  ```

  ```ini
  # in pg_hba.conf file
  local   all             geocitizen                              md5
  ```

### Pipeline

SonarQube Web console has implemented quides for different CI way, for example Jenkins CI -> http://<ip-of-sonar>:9000/tutorials?id=com.softserveinc%3Ageo-citizen&selectedTutorial=jenkins

SonarQube creds in *pom.xml* -> [sonarcube](https://community.sonarsource.com/t/mvn-sonar-sonar-cannot-login/12650)

SonarScanner for Maven -> [sonarcube](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)

Maven lifecycle -> [stackoverflow](https://stackoverflow.com/questions/16602017/how-are-mvn-clean-package-and-mvn-clean-install-different)

Maven phases:goals -> [sysout](https://sysout.ru/maven-goals-i-phases/)

SonarQube REST API examples -> [ibm](https://ibm.github.io/sonarqube/get-started-with-sonarqube/)

Run SonarQube Gate by Maven:

  ```bash
  ~ mvn clean verify sonar:sonar -Dsonar.login=<only-token>

  ```

Guide for 'enabling' test coverage metrics -> [baeldung](https://www.baeldung.com/sonarqube-jacoco-code-coverage)

Pipeline ? -> [stackoverflow](https://stackoverflow.com/a/44904039)

Integrate SonarQube & Jenkins (indian) -> [youtube](https://www.youtube.com/watch?v=Spzk1lrCgNY)

Integrate SonarQube & Jenkins (darinpope) -> [youtube](https://www.youtube.com/watch?v=KsTMy0920go)

Integrate SonarQube & Jenkins (manual) -> [jenkins](https://www.jenkins.io/doc/pipeline/steps/sonar/)

## Kubernetes

### k8s

Installation (all following sub-steps must be performed on each VMs - master, worker1, worker2 ... etc.):

- create new GCP instance with Debian 11

- install Docker

  ```bash
  ~ sudo apt update
  ~ sudo apt install \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

  ~ curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  ~ echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  ~ sudo apt update
  ~ sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # if you have .sock permission errors perform following steps ...
  ~ sudo groupadd docker
  ~ sudo usermod -aG docker ${USER}
  ~ sudo reboot now
  ```

- install k8s

  ```bash
  ~ sudo apt install apt-transport-https

  ~ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
  ~ cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
      deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF

  ~ sudo apt update
  ~ suo apt install -y kubelet kubeadm kubectl
  ```

- additional configuring for k8s

  ```bash
  ~ sudo swapoff -a
  ```

Initialize first k8s cluster (on master node)

  ```bash
  # '--pod-network-cidr' and it's argument is mandatory for this guide due to Flanel CNI !!!
  ~ sudo kubeadm init --pod-network-cidr=10.244.0.0/16
  ```

If everything is OK, in the end you can see string 'kubeadm join <ip:port> --token ...' for joining you worker-node to your master-node. Do not worry, you can retrieve this connect-string any time with next command

  ```bash
  ~ sudo kubeadm token create --print-join-command
  ```

Relocate k8s main config for default user

  ```bash
  # create home folder for cluster
  ~ mkdir -p $HOME/.kube
  
  # copy generated settings to this folder
  ~ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

  # change ownership from root to default/current user
  ~ sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```

Check base info about your cluster

  ```bash
  ~ sudo kubectl get nodes
  ~ sudo kubectl get namespaces
  ~ sudo kubectl get pods --all-namespaces
  ```

**TIP**: if you get error 'The connection to the server localhost:8080 was refused' after previous command(s) - there is:
- problem with *.kube* directory - check ownership, permissions, content of folder etc.  
**OR**
- problem with firewall - if you did some connection/firewall changes on instance.

At this step you must see after ***kubectl get nodes*** info with one node - master node with name of your machine. Node has status 'NotReady' because the cluster does not have pod-network configs / CNI. There are multiple CNI (container network interface):
- Flannel
- Calico
- Canal
- Weave  

... (first two are the most common)
  
To setup pod networking (Flannel in our case)

  ```bash
  ~ kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
  ```

Now status of master node must be 'Ready'.

**IMPORTANT**: Check if CNI is configured and work corectlly by runing ***kubectl get pods*** -> all pods have to have *Status* 'Runing' !!!  
Otherwise -> something went wrong with CNI !!!  
For Flannel CNI ***kubeadm init*** must be executed with *--pod-network-cidr=10.244.0.0/16* (this argument is default, but you can choose other one) !!!

Connect configured worker-nodes (on worker node)

  ```bash
  # sudo kubeadm token create --print-join-command - if you lost connection string :)
  ~ kubeadm join <ip>:<port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
  ```

If worker connected succesfully you have to see output like:

  ```md
  This node has joined the cluster:
  * Certificate signing request was sent to apiserver and a response was received.
  * The Kubelet was informed of the new secure connection details.

  Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
  ```

So, run ***kubectl get nodes*** on master node to see new woker node.

**TIP**: new node has role with tag *none* by default. If you want to change this tag use command

  ```bash
  ~ kubectl label node <name> node-role.kubernetes.io/worker=<new-tag>
  ```

To prove correct configuration of k8s try a simple example -> [docker](https://docs.docker.com/get-started/orchestration/)

  - to connect to pods use
    
    ```bash
    ~ kubectl exec -it <name> -- sh
    ```

To create k8s cred to your private Docker registry

- register on Docker Hub

- create your public/private registry

- create access token to this registry with some rules

- on your k8s master-node instance try to login into the registry 

  ```bash
  # after this command you will be asked to prompt your pass/access token
  ~ docker login -u <username>

  # prompt your access token
  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  ```

- now you have to see that your creds will be stored in *${HOME}/.docker/config.json* unencrypted

- use this tutorial to create k8s creds with this registry cred -> [kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

  - in my case i used .yaml style of creating creds object, because you can specify aditional fields (like *namespace*) and manage this creds like a resource (this is cred_docker.yaml)

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: some-name
      namespace: some-space
    data:
      .dockerconfigjson: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx...
    type: kubernetes.io/dockerconfigjson
    ```

  - *.dockerconfigjson* is value generated by command

    ```bash
    ~ cat ~/.docker/config.json | base64
    ```

  - apply this yaml file to generate cred object

    ```bash
    ~ kuectl apply -f cred_docker.yaml
    ```

  - now you can use this cred in other yaml files to pull Docker images from your Docker registry without direct usage of Docker creds or routine passing this creds on each k8s worker-node

  - check this tutorial for more details also -> [blog](https://blog.cloudhelix.io/using-a-private-docker-registry-with-kubernetes-f8d5f6b8f646)

## SRE & SLA/SLO/SLI

### Theory

SRE methodology explanation (ru) -> [atlassian](https://www.atlassian.com/ru/incident-management/devops/sre)

Simple explanation of SLA/SLO/SLI philosophy (ru) -> [atlassian](https://www.atlassian.com/ru/incident-management/kpis/sla-vs-slo-vs-sli)

Error budget (ru) -> [atlassian](https://www.atlassian.com/ru/incident-management/kpis/error-budget)

**CONCLUSION**: as a result we have:

- SLA - list of agreements with stackeholder about healthy level of quality

- SLO - list of obejectives/goals that a team must hit to mee SLA

- SLI - metrics used to evaluate SLO

- SRE - team/worker that used methodology of SLO/SLI to observe and analys of project

Main object of all this thing is reliability level number presented in the form of percents. Ideal level for project is 99.99% of reliability. The 100% level is utopia and this number is never used.

- What is this methodology in real work ?
- Just specific set of rules to collect metrics from our project (VMs, instances, servers, DBs ...) and calculating them in specific way to get very simple reliability plot of project (with failures) and with reliability level number (mandatory !).

- Do we just need some metric collector (like Prometheus, Graphite, SensuGo ...) and metric visualiser (Grafana, Kibana, Datadog ...) and special set of metric rules to this tools ?
- Yes. Earlier SRE engineer connect and write rules for this metric in raw form (for metric collector and visualiser directly). But now for kit Prometheus-Grafana we can write SLO/SLI in simple form (yaml format) and then get rules for metrics-alerts-metadata in Prometheus form (also yaml format). And this is *slok/sloth* project ...

### Slok/Sloth

Main site of slok/sloth -> [sloth](https://sloth.dev/)

GitHub of slok/sloth -> [github](https://github.com/slok/sloth)

More info about slok/sloth -> [joyk](https://www.joyk.com/dig/detail/1625546903371171)

Examples of slok/sloth API v1 (latest) usage -> [github](https://github.com/slok/sloth/tree/main/pkg/prometheus/api/v1)

slok/sloth is written on Golang so ... -> [pkg.go](https://pkg.go.dev/github.com/slok/sloth@v0.6.0/pkg/prometheus/api/v1)

**INFO**: in fact slok/sloth is very useful and handy converter of simple SLO spec (from slok/sloth yaml 'syntax') to terrific Prometheus rules (also yaml form).

To install slok/sloth -> [sloth](https://sloth.dev/introduction/install/)

- Docker way - actually you have to pack input .yaml file to new Docker image (based on the origin) and then run this new image like

  ```bash
  # you will get yaml output of Prometheus rules to the stdout
  # if you will use '-o' or '--out' to output rules to file - this file will be generated inside of container obviously  
  ~ docker run -it <my-new-sloth-image> generate -i <path-to-file-in-image>
  ```

- Source way - *make build* uses Docker containers while build slok/sloth - this stuff consume almost 2-3GB of RAM at some point

- k8s way - this case is advisable when all project, metric collector, monitoring system are deployed arleady on k8s cluster

After build (Source way) you get *sloth* folder with *bin* folder with *sloth-linux-amd64* binary file (or similar name, depends of your environment because binary file is builded specialy for host system as you can see in it's name). Move this binary to */usr/bin* (rename as *sloth*) with *+x* mode and enjoy).  
*sloth* has '--help' and '--help-long' manuals of course ...

Simple example to first usage of SLO by slok/sloth -> [sloth](https://sloth.dev/introduction/)

- create *some.yaml* file with 'SLO spec'

- call the command

  ```bash
  # to get rules in file
  ~ sloth generate -i some.yaml -o result.yaml

  # to get rules in stdout
  ~ sloth generate -i some.yaml
  ```

- you get Prometheus rules in *result.yaml* file / stdout !

- move the file with rules to your Prometheus 'main' folder - in most cases */etc/prometheus/* (it contain *prometheus.yml* main config file)

- rename file with rules like *prometheus.rules.yml* - this not mandatory but preffer ...

- add entrypoint for this rule file to Prometheus config file *prometheus.yml*

  ```yaml
  rule_files:
  - 'prometheus.rules.yml'
  ```

  - some info about Prometheus rules -> [softwareadept](https://softwareadept.xyz/2018/01/how-to-write-rules-for-prometheus/)

- restart Prometheus service by *systemctl* (if Prometheus is installled like regular app)

- open Prometheus web interface and check new settings from *prometheus.rules.yml* 

  - 'Rules' - new alert rules
  - 'Status-Rules' - new metric rules

- open Grafana web interface

- import new slok/sloth (actually SLO) dashboards from -> [grafana1](https://grafana.com/grafana/dashboards/14348) and [grafana2](https://grafana.com/grafana/dashboards/14643)
  - of cource use Prometheus as source for this dasboards

- enjoy)

## Price calculating

GCP -> [google](https://cloud.google.com/products/calculator)

AWS -> [amazon](https://calculator.aws/#/addService)

- select *Amazon EC2* -> [amazon](https://calculator.aws/#/createCalculator/EC2)

- select ...

Oracle -> [oracle](https://www.oracle.com/cloud/costestimator.html)

## Appendix

### Maven and Bash

Some command for outputs:

  ```bash
  # print test log to file
  ~  mvn test --log-file mvn_test.log
  
  # grep only main line with [heads]
  ~ cat mvn_test.log | grep --color=never '\[INFO\]\|\[ERROR\]\|\[WARNING\]'

  # output log after 'mvn test' in original coloring
  ~ mvn test --log-file my_temp.log && \
    cat my_temp.log | grep --color=never '\[INFO\]\|\[ERROR\]\|\[WARNING\]' |  
    GREP_COLOR='01;34' grep --color=always 'INFO\|$' | 
    GREP_COLOR='01;31' grep --color=always 'ERROR\|$' |  
    GREP_COLOR='01;93' grep --color=always 'WARNING\|$' && \
    rm my_temp.log
  ```

Workflow to demonstrate:

  ```bash
  # origin state
  ~ ./geo.sh
  ~ ./test.sh

  # full tests
  ~ ./unignore_full.sh
  ~ ./test.sh

  # skip 'bad' tests
  ~ ./geo.sh
  ~ ./unignore_part.sh
  ~ ./test.sh

  # only 'good' test files
  ~ ./delete.sh
  ~ ./test.sh
  ```

Command *grep* can color it's output:

- GREP_COLOR='01;34' - greyish blue
- GREP_COLOR='01;93' - yellow
- GREP_COLOR='01;31' - dull red

### SonarQube

Example of SonarQube API usage:

  ```bash
  # generate new token with 'name' for user/owner of '<token>:'
  # this token can be found in the user profile then
  ~ curl -s -X POST --user <token>: http://<url>:9000/api/user_tokens/generate?name=test | jq

  # get status of last analysis of project with key (key can be found in 'Project Information' in 'Project' page)
  ~ curl -s -X POST --user <token>: http://wlados-sonarqube.ddns.net:9000/api/qualitygates/project_status?projectKey=<key> | jq

  # get configs of some Gate by it's id
  ~ curl -s -X POST --user <token>: http://wlados-sonarqube.ddns.net:9000/api/qualitygates/show?id=<id> | jq
  ```

### k8s

Some usefull getters

  ```bash
  ~ sudo kubectl get nodes
  ~ sudo kubectl get namespaces
  ~ sudo kubectl get pods --all-namespaces
  ```

Some usefull setters

  ```bash
  ~ kubectl config set-context --current --namespace=my-namespace

  ```

Get connection string again

  ```bash
  ~ sudo kubeadm token create --print-join-command
  ```

Change role tag

  ```bash
  ~ kubectl label node <name> node-role.kubernetes.io/worker=<new-tag>
  ```

To delete node

- Find the node with ***kubectl get nodes***. We’ll assume the name of node to be removed is “mynode”, replace that going forward with the actual node name.
- Drain it with ***kubectl drain mynode***
- Delete it with ***kubectl delete node mynode***
- On worker node 
  - clean all posible states and configs automatically ***kubeadm reset***
  - clean CNI configs ***sudo rm -rf /etc/cni/net.d/***
  - delete main configs folder ***$HOME/.kube/config***

Namespace vs context -> [stackoverflow](https://stackoverflow.com/questions/61171487/what-is-the-difference-between-namespaces-and-contexts-in-kubernetes)

*Deployment* + *Service* -> [kubernetes](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)

About port types -> [bmc](https://www.bmc.com/blogs/kubernetes-port-targetport-nodeport/)

Service for validation k8s yaml files -> [validkube](https://validkube.com/)

Base k8s yaml file explanation -> [Kubernetes](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)

- apiVersion -> [matthewpalmer](https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-apiversion-definition-guide.html)

- kind -> [medium](https://chkrishna.medium.com/kubernetes-objects-e0a8b93b5cdc)

- spec -> [kubernetes](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)


apiVer

behavior:
  scaleDown:
    stabilizationWindowSeconds: 300
    policies:
    - type: Percent
      value: 100
      periodSeconds: 15
  scaleUp:
    stabilizationWindowSeconds: 0
    policies:
    - type: Percent
      value: 100
      periodSeconds: 15
    - type: Pods
      value: 4
      periodSeconds: 15
    selectPolicy: Max


apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m    


apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: autoscaler-geocitizen
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: geocitizen
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 75            