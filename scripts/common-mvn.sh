is_repo_local() {
    if [ `basename $MAVEN_REPO_BASE_URL` = '.m2' ]; then
		return;
	fi

	false
}