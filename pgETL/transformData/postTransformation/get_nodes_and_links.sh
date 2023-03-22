while getopts i:o: flag
do
    case "${flag}" in
        i) id=${OPTARG};;
        o) output=${OPTARG};;
        *) echo "usage: $0 [-i] [-o]" >&2
        exit 1 ;;
    esac
done
psql -d prod -f network_nodes_and_links.sql -v oa_id=$id -A -t -q -o $output