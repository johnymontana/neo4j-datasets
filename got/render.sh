echo "Usage: sh render.sh [publish]"
GUIDES=../neo4j-guides

function render {
$GUIDES/run.sh index.adoc index.html +1 "$@"
}

if [ "$1" == "publish" ]; then
	URL=guides.neo4j.com/communitydemo
	render http://$URL -a csv-url=http://guides.neo4j.com/data/got -a env-training
	s3cmd put --recursive -P *.html img s3://${URL}/
	s3cmd put -P index.html s3://${URL}

	URL=guides.neo4j.com/communitydemo
	render http://$URL -a env-training -a csv-url=file:///
	s3cmd put --recursive -P *.html img s3://${URL}/
	s3cmd put -P index.html s3://${URL}
	echo "Publication Done"
else
	URL=localhost:8001/community
	# copy the csv files to $NEO4J_HOME/import
	render http://$URL -a csv-url=file:/// -a env-training
	echo "Starting Websever at $URL Ctrl-c to stop"
	python $GUIDES/http-server.py
fi
