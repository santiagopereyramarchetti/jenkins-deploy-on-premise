pipeline{

    agent {
        docker {
            image 'debian:bullseye'
            args '--name my-pipeline-debian --user root'
        }
    }

    triggers {
        pollSCM('H * * * *')
    }

    environment {
        PROJECT_NAME="on-premise"
        GITHUB_REPO=https://github.com/santiagopereyramarchetti/on-premise.git

        DB_CONNECTION="mysql"
        DB_HOST="127.0.0.1"
        DB_PORT="3306"
        DB_NAME="backend"
        DB_USER="backend"
        DB_PASSWORD="password"
        DB_HOST_MYSQL="localhost"
        
        REMOTE_HOST = 'vagrant@192.168.10.50'
    }

    stages{
        stage("Preparando todo el entorno"){
            steps{
                script{
                    sh 'bash ./docker/server-provision.sh'
                }
            }
        }
        stage("Build"){
            steps{
                script{
                    sh '''
                        ./docker/project-install.sh '${DB_CONNECTION}' \
                            '${DB_HOST}' \
                            '${DB_PORT}' \
                            '${DB_NAME}' \
                            '${DB_USER}' \
                            '${DB_PASSWORD}' \
                            '${DB_HOST_MYSQL}' \
                    '''
                }
            }
        }
        // Agregar los paquetes necesarios para ejecutar los test. Esto
        // hacerlo usando la image creada para este proyecto y poniendo
        // volumes hacia el código, asi se actualiza cuando agreamos
        // bibliotecas.

        // docker run -d --name my-onpremise -v ./backend:/var/www/backend -v ./frontend:/var/www/frontend -p 9595:80 my-environment
        
        // También ejecutar los comandos de los test dentro del container para ver si fallan
        stage("Análisis de código estático"){
            steps{
                sh './backend/vendor/bin/phpstan analyse'
            }
        }
        stage("Análisis de la calidad del código"){
            steps{
                def userInput = input(
                    message: 'Ejecutar este step?',
                    parameters:[
                        choice(name: 'Selecciona una opción', choice: ['Si', 'No'], description: 'Elegir si queres ejecutar este step')
                    ]
                )
                if (userInput == 'Si'){
                    sh 'php ./backend/artisan insights --no-interaction --min-quality=90 --min-complexity=90 --min-architecture=90 --min-style=90'
                }else{
                    echo 'Step omitido. Siguiendo adelante...'
                }
            }
        }
        stage("Test unitarios"){
            steps{
                script{
                    sh 'php ./backend/artisan test'
                }
            }
        }
        stage("Deployando nueva release"){
            steps{
                script{
                    sh '''
                        scp -o StrictHostKeyChecking=no ./docker/project-deploy.sh ${REMOTE_HOST}:~/project-deploy.sh
                        ssh -o StrictHostKeyChecking=no ${REMOTE_HOST} "bash ~/project-deploy.sh '${PROJECT_NAME}' \
                            '${GITHUB_REPO}'
                            '${DB_CONNECTION}' \
                            '${DB_HOST}' \
                            '${DB_PORT}' \
                            '${DB_NAME}' \
                            '${DB_USER}' \
                            '${DB_PASSWORD}' \
                            '${DB_HOST_MYSQL}' \
                    '''
                }  
            }
        }
    }
    


}