DOCKER_CFG_DIR=/home/$USER/docker_setup

dup(){
d_act="$pwd"
id=${1}
cd $DOCKER_CFG_DIR/$id
docker compose up -d
cd $d_act
}

ddown(){
d_act="$pwd"
id=${1}
cd $DOCKER_CFG_DIR/$id
docker compose down
cd $d_act
}

dex(){
id=${1}
docker exec -it $id /bin/bash
}

dcreate(){
	act_dir="$pwd"
	cd $DOCKER_CFG_DIR 
	mkdir ${1}
	cp $DOCKER_CFG_DIR/as2_base/docker_compose.yml ${1}/docker_compose.yml
}
