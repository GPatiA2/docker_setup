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

dupex(){
id=${1}
dup $id
dex $id
}

dcreate(){
    # Check for required parameter
    if [ $# -lt 1 ]; then
        echo "Error: Container name is required"
        echo "Usage: dcreate <container_name> [--image <image_name>] [volume1 volume2 ...]"
        return 1
    fi
    
    dname="$1"
    shift
    
    image=""
    
    # Check for optional --image flag
    if [ "$1" = "--image" ]; then
        shift
        if [ $# -lt 1 ]; then
            echo "Error: --image flag requires an image name"
            return 1
        fi
        image="$1"
        shift
    fi
    
    mkdir -p "${DOCKER_CFG_DIR}/$dname"
    touch "${DOCKER_CFG_DIR}/$dname/.mybashrc"
    
    echo "Mounting volumes $@"
    
    # Build arguments for Python script
    if [ -n "$image" ]; then
        python3 "${DOCKER_CFG_DIR}/common/customize_compose.py" \
            -in "${DOCKER_BASE_IMG}/docker-compose.yml" \
            -i "$image" \
            -v "$@" \
            -n "$dname"
    else
        python3 "${DOCKER_CFG_DIR}/common/customize_compose.py" \
            -in "${DOCKER_BASE_IMG}/docker-compose.yml" \
            -v "$@" \
            -n "$dname"
    fi
    
    # Process volumes
    for volume in "$@"
    do
	echo Adding $"volume"
        vol_name=$(basename "$volume")
        vol_path="/root/$vol_name"
        echo "if [ -d $vol_path/install ]; then source $vol_path/install/setup.bash; fi" >> "${DOCKER_CFG_DIR}/$dname/.mybashrc"
    done

    cat ${DOCKER_CFG_DIR}/common/colcon_commands.bash >> ${DOCKER_CFG_DIR}/$dname/.mybashrc
}

dls(){
	k="0"
	for i in $(ls "${DOCKER_CFG_DIR}")
	do
		echo ${k} - ${i}
		k="$((k + 1))"
	done
}

dhelp(){
	echo "Available commands:"
	echo "  dup    <id>              - Start a docker compose service"
	echo "  ddown  <id>              - Stop a docker compose service"
	echo "  dex    <id>              - Exec into a running container"
	echo "  dupex  <id>              - Start and exec into a container"
	echo "  dcreate <name> [--image <img>] [volumes...] - Create a new container config"
	echo "  dls                      - List available docker configs"
	echo "  dvol   <id>              - Show docker-compose.yml for a config"
	echo "  dcd                      - cd to DOCKER_CFG_DIR"
	echo "  dedit  <id>              - Edit docker-compose.yml for a config"
	echo "  dhelp                    - Show this help message"
}

dvol(){
	cat "${DOCKER_CFG_DIR}/${1}/docker-compose.yml"
}

dcd(){
	cd "${DOCKER_CFG_DIR}"
}

dedit(){
	if [ -z "${1}" ]; then
		echo "Provide a docker directory. Available ones: "
		ls "${DOCKER_CFG_DIR}"
		return 	
	fi
	dcd
	cd ${1}
	vim docker-compose.yml
}

_dbasic_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local docker_cfg_dir="${DOCKER_CFG_DIR}"
    
    # If DOCKER_CFG_DIR is not set or doesn't exist, return
    if [[ -z "$docker_cfg_dir" ]] || [[ ! -d "$docker_cfg_dir" ]]; then
        return 0
    fi
    
    # Get directories in DOCKER_CFG_DIR (excluding hidden dirs and . ..)
    local dirs=$(cd "$docker_cfg_dir" && find . -maxdepth 1 -type d ! -name '.' ! -name '..*' -printf '%f\n' 2>/dev/null)
    
    # Generate completions matching the current word
    COMPREPLY=($(compgen -W "$dirs" -- "$cur"))
}

complete -F _dbasic_completion dup
complete -F _dbasic_completion dupex
complete -F _dbasic_completion ddown
complete -F _dbasic_completion dex
complete -F _dbasic_completion dvol
complete -F _dbasic_completion dedit
