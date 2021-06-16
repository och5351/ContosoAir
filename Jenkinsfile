/*
   * jenkins podtemplete document
     * https://www.jenkins.io/doc/pipeline/steps/kubernetes/#podtemplate-define-a-podtemplate-to-use-in-the-kubernetes-plugin
   * 예제 Groovy code 
     * https://tech.osci.kr/2019/11/21/86026733/
*/
podTemplate(label: 'jenkins-slave-pod',  //jenkins slave pod name
  containers: [
    containerTemplate(
      name: 'git', // container 에 git 설정
      image: 'alpine/git',
      command: 'cat',
      ttyEnabled: true
    ),
    /*
    containerTemplate(
      name: 'maven', // container 에 maven 설정
      image: 'maven:3.6.2-jdk-8',
      command: 'cat',
      ttyEnabled: true
    ),*/
    containerTemplate(
      name: 'node', // container 에 node 설정
      image: 'node:8.16.2-alpine3.10',
      command: 'cat',
      ttyEnabled: true
    ),
    containerTemplate(
      name: 'docker',
      image: 'docker',
      command: 'cat',
      ttyEnabled: true
    ),
  ],
  volumes: [ 
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'), 
  ]
)

{
    node('jenkins-slave-pod') {  // 상위에 node 작성 'jenkins-slave-pod' 
        def registry = "hub.docker.com/repository/docker/och5351/kubernetes_test" // docker 저장소
        //def registryCredential = "nexus3-docker-registry"
        /*
          * jenkins scm document
            * https://www.jenkins.io/doc/pipeline/steps/workflow-scm-step/
        */
        // jenkins Clone Stage는 Jenkins 내부에서 구현
        stage('Clone repository') {
            container('git') {
                // https://gitlab.com/gitlab-org/gitlab-foss/issues/38910
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [
                        [url: 'https://github.com/och5351/ContosoAir.git']//, credentialsId: 'gitlab-account']
                    ],
                ])
            }
        }
        
        stage('build the source code via npm') {
            container('node') {
                sh 'npm install'
                sh 'npm build'
            }
        }
        /*
        stage('build the source code via maven') {
            container('maven') {
                sh 'mvn package'
                sh 'bash build.sh'
            }
        }
        */
        stage('Build docker image') {
            container('docker') {
                withDockerRegistry([ /*credentialsId: "$registryCredential",*/ url: "http://$registry" ]) {
                    sh "docker build -t $registry -f ./Dockerfile ."
                }
            }
        }

        stage('Push docker image') {
            container('docker') {
                withDockerRegistry([ /*credentialsId: "$registryCredential",*/ url: "http://$registry" ]) {
                    docker.image("$registry").push()
                }
            }
        }
    }   
}
