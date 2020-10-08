function is_maven_repo_local {
    if [ `basename $MAVEN_REPO_BASE_URL` = '.m2' ]; then
		return;
	fi

	false
}

function get_maven_asset_path {
	local asset_repo=$1
	local asset_path=$2
	local asset_type=$3
	local asset_version=$4

	if is_maven_repo_local; then
		asset_name=`basename $asset_path`
		echo "$MAVEN_REPO_BASE_URL/$asset_repo/$asset_path/$asset_version/$asset_name-$asset_version.$asset_type"
	else
		echo "$MAVEN_REPO_BASE_URL/$asset_repo/$asset_path.$asset_type"
	fi
}