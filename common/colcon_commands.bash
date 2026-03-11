
# Detect the colcon workspace root by walking up from the current directory.
# A workspace is identified by having a 'src' subdirectory alongside at least
# one of: build, install, log. Falls back to $COLCON_WS, then $(pwd).
_colcon_find_workspace() {
    local dir
    dir="$(pwd)"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/src" ]] && [[ -d "$dir/build" || -d "$dir/install" || -d "$dir/log" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    # Fallback: src-only workspace (not yet built)
    dir="$(pwd)"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/src" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    # Last resort
    echo "${COLCON_WS:-$(pwd)}"
}

# Help for colcon aliases
chelp() {
    echo "Colcon aliases:"
    echo ""
    echo "  cb [--packages-select <pkg>...] [<args>...]"
    echo "      colcon build wrapper."
    echo "      Always compiles with -DCMAKE_EXPORT_COMPILE_COMMANDS=ON."
    echo "      Merges all build/<pkg>/compile_commands.json into build/compile_commands.json."
    echo ""
    echo "  ct [<args>...]"
    echo "      colcon test wrapper."
    echo "      Always runs with --event-handlers console_direct+."
    echo ""
    echo "  cclean <pkg> [<pkg2>...]"
    echo "      Removes build/<pkg> and install/<pkg> for each given package."
    echo ""
    echo "  chelp"
    echo "      Show this help message."
    echo ""
    echo "  Workspace root is auto-detected by walking up from the current directory,"
    echo "  looking for a directory with a 'src' folder next to build/install/log."
    echo "  Override by setting \$COLCON_WS."
}

# Colcon build wrapper with automatic compile_commands.json merging
cb() {
    local packages=()
    local args=()
    local workspace_dir
    workspace_dir="$(_colcon_find_workspace)"

    echo "Workspace: ${workspace_dir}"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --packages-select)
                shift
                while [[ $# -gt 0 && "$1" != --* ]]; do
                    packages+=("$1")
                    shift
                done
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    # Build the colcon command
    local colcon_cmd=(colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON)

    if [[ ${#packages[@]} -gt 0 ]]; then
        colcon_cmd+=(--packages-select "${packages[@]}")
    fi

    colcon_cmd+=("${args[@]}")

    echo "Running: ${colcon_cmd[*]}"
    (cd "$workspace_dir" && "${colcon_cmd[@]}")
    local build_result=$?

    # Merge compile_commands.json files
    local build_dir="${workspace_dir}/build"
    local output_file="${build_dir}/compile_commands.json"

    if [[ -d "$build_dir" ]]; then
        local json_files=()

        if [[ ${#packages[@]} -gt 0 ]]; then
            # Only merge for selected packages (plus existing merged file content)
            for pkg in "${packages[@]}"; do
                local pkg_cc="${build_dir}/${pkg}/compile_commands.json"
                [[ -f "$pkg_cc" ]] && json_files+=("$pkg_cc")
            done
        else
            # Merge all packages
            while IFS= read -r -d '' f; do
                json_files+=("$f")
            done < <(find "$build_dir" -mindepth 2 -maxdepth 2 -name "compile_commands.json" -not -path "${output_file}" -print0)
        fi

        if [[ ${#json_files[@]} -gt 0 ]]; then
            echo "Merging compile_commands.json from ${#json_files[@]} package(s) into ${output_file}..."

            # If merging selected packages only, preserve existing entries from other packages
            if [[ ${#packages[@]} -gt 0 && -f "$output_file" ]]; then
                # Build a jq filter to exclude entries from selected packages' build dirs,
                # then append new entries from those packages
                local exclude_filter=""
                for pkg in "${packages[@]}"; do
                    exclude_filter+=" | map(select(.file | startswith(\"${build_dir}/${pkg}/\") | not))"
                done

                local existing
                existing=$(jq "${exclude_filter}" "$output_file" 2>/dev/null || echo "[]")

                local new_entries="[]"
                for f in "${json_files[@]}"; do
                    new_entries=$(jq -s '.[0] + .[1]' <(echo "$new_entries") "$f" 2>/dev/null || echo "$new_entries")
                done

                jq -s '.[0] + .[1]' <(echo "$existing") <(echo "$new_entries") > "$output_file"
            else
                # Simple full merge
                jq -s '[.[] | .[]]' "${json_files[@]}" > "$output_file"
            fi

            echo "Done: ${output_file}"
        else
            echo "No compile_commands.json files found to merge."
        fi
    fi

    return $build_result
}

# Colcon test wrapper with console_direct+ event handler always on
ct() {
    local workspace_dir
    workspace_dir="$(_colcon_find_workspace)"
    echo "Workspace: ${workspace_dir}"
    echo "Running: colcon test --event-handlers console_direct+ $*"
    (cd "$workspace_dir" && colcon test --event-handlers console_direct+ "$@")
}

# Clean build and install artifacts for a specific package
cclean() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: cclean <package_name> [<package_name2> ...]"
        echo "Removes build/<package> and install/<package> directories."
        return 1
    fi

    local workspace_dir
    workspace_dir="$(_colcon_find_workspace)"
    echo "Workspace: ${workspace_dir}"

    for pkg in "$@"; do
        local build_path="${workspace_dir}/build/${pkg}"
        local install_path="${workspace_dir}/install/${pkg}"
        local removed=0

        if [[ -d "$build_path" ]]; then
            echo "Removing ${build_path}"
            rm -rf "$build_path"
            removed=1
        fi

        if [[ -d "$install_path" ]]; then
            echo "Removing ${install_path}"
            rm -rf "$install_path"
            removed=1
        fi

        if [[ $removed -eq 0 ]]; then
            echo "Nothing to clean for package '${pkg}' (no build or install directory found)."
        else
            echo "Cleaned '${pkg}'."
        fi
    done
}
