/*
   * jenkins podtemplete document
     * https://www.jenkins.io/doc/pipeline/steps/kubernetes/#podtemplate-define-a-podtemplate-to-use-in-the-kubernetes-plugin
   * 예제 Groovy code 
     * https://tech.osci.kr/2019/11/21/86026733/
     test
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
    containerTemplate(
      name: 'kubectl', 
      image: 'lachlanevenson/k8s-kubectl:v1.15.3', 
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
        def DOCKER_IMAGE_NAME = "och5351/kubernetes_test"           // 생성하는 Docker image 이름
        def DOCKER_IMAGE_TAGS = "test_app"  // 생성하는 Docker image 태그
        def NAMESPACE = "contoso-air"
        def USERNAME = "och5351"
        def PASSWORD = "SWEETlove!%38"
        def DATE = new Date();
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
                //sh 'SET %COSMOS_DB_NAME%=168.61.40.247:27017'
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
        stage('Docker build') {
            container('docker') {
              /*
                withDockerRegistry([ credentialsId: "$registryCredential", url: "http://$registry" ]) {
                    sh "docker build -t $registry -f ./Dockerfile ."
                }*/
             
                 //app = docker.build("och5351/kubernetes_test")
                 
              withCredentials([usernamePassword(
                    credentialsId: 'docker-hub',
                    usernameVariable: 'och5351',
                    passwordVariable: 'SWEETlove!%38')]) {
                        /* ./build/libs 생성된 jar파일을 도커파일을 활용하여 도커 빌드를 수행한다 */
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAGS} ."
                        sh "docker login -u ${USERNAME} -p ${PASSWORD}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAGS}"
                }
            }
        }
      
      stage('Run kubectl') {
            container('kubectl') {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub',
                    usernameVariable: 'och5351',
                    passwordVariable: 'SWEETlove!%38')]) {
                        /* namespace 존재여부 확인. 미존재시 namespace 생성 */
                        sh "kubectl get ns ${NAMESPACE}|| kubectl create ns ${NAMESPACE}"

                        /* secret 존재여부 확인
                        . 미존재시 secret 생성 */
                        sh """
                            kubectl get secret my-secret -n ${NAMESPACE} || \
                            kubectl create secret docker-registry my-secret \
                            --docker-server=https://index.docker.io/v1/ \
                            --docker-username=${USERNAME} \
                            --docker-password=${PASSWORD} \
                            --docker-email=dhcksgo5319@naver.com \
                            -n ${NAMESPACE}
                        """
                        /* k8s-deployment.yaml 의 env값을 수정해준다(DATE로). 배포시 수정을 해주지 않으면 변경된 내용이 정상 배포되지 않는다. */
                        /*sh "echo ${VERSION}"
                        sh "sed -i.bak 's#VERSION_STRING#${VERSION}#' ./k8s/k8s-deployment.yaml"*/
                        sh "echo ${DATE}"
                        sh "sed -i.bak 's#DATE_STRING#${DATE}#' ./k8s/k8s-deployment.yaml"

                        /* yaml파일로 배포를 수행한다 */
                        // sh "kubectl apply -f ./k8s/k8s-deployment.yaml -n ${NAMESPACE}"
                        // sh "kubectl apply -f ./k8s/k8s-service.yaml -n ${NAMESPACE}"
                        sh "kubectl apply -f ./k8s/k8s-deployment.yaml -n ${NAMESPACE}"
                        sh "kubectl apply -f ./k8s/k8s-service.yaml -n ${NAMESPACE}"
                }
            }
      }
      
    }   
}
