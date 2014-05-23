alias docker_clean_containers="docker rm `docker ps -a | grep Exited | awk '{print $1}'`"
alias docker_clean_images="docker rmi `docker images -aq`"
alias boot2docker_start="boot2docker ssh -L 8888:localhost:8888"
