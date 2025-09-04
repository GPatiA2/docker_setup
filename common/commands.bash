dup(){
d_act="$pwd"
id=${1}
cd "${DOCKER_CFG_DIR}"/$id
docker compose up -d
cd $d_act
}

ddown(){
d_act="$pwd"
id=${1}
cd "${DOCKER_CFG_DIR}"/$id
docker compose down
cd $d_act
}

dex(){
id=${1}
docker exec -it $id /bin/bash
}

dcreate(){
	dname=${1}
	image=${2}
	mkdir -p "${DOCKER_CFG_DIR}"/$dname
	touch "${DOCKER_CFG_DIR}"/$dname/.mybashrc
	shift
	shift
	python3 "${DOCKER_CFG_DIR}"/common/customize_compose.py -in "${DOCKER_CFG_DIR}"/common/as2_base/docker-compose.yml -i $image -v "$@" -n $dname
	for volume in "$@"
	do
		vol_name=$(basename "$volume")
		vol_path=/root/$vol_name	
		echo "if [ -d  $vol_path/install ]; then source $vol_path/install/setup.bash; fi" >> "${DOCKER_CFG_DIR}"/$dname/.mybashrc
	done
}
