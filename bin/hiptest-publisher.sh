#! /bin/bash
docker run --interactive --tty --rm --user $UID --volume $(pwd):/app unitive/hiptest-publisher  "$@"
