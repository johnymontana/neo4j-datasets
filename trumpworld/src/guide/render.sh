echo "Usage: sh render.sh [publish]"
GUIDES=../../../neo4j-guides

function render {
$GUIDES/run.sh index.adoc index.html +1 "$@"
$GUIDES/run.sh intro.adoc intro.html +1 "$@"
$GUIDES/run.sh import.adoc import.html +1 "$@"
$GUIDES/run.sh sna.adoc sna.html +1 "$@"
$GUIDES/run.sh contracts.adoc contracts.html +1 "$@"
$GUIDES/run.sh exploratory.adoc exploratory.html +1 "$@"
}

if [ "$1" == "publish" ]; then
	URL=guides.neo4j.com/trumpworld
	render http://$URL -a csv-url=http://guides.neo4j.com/trumpworld/data -a env-training
	s3cmd put --recursive -P *.html img s3://${URL}/
	s3cmd put -P index.html s3://${URL}

	URL=guides.neo4j.com/trumpworld/file
	render http://$URL -a env-training -a csv-url=file:///
	s3cmd put --recursive -P *.html img s3://${URL}/
	s3cmd put -P index.html s3://${URL}
else
	URL=localhost:8001/trumpworld
	render http://$URL -a csv-url=file:/// -a env-training
	echo "Starting webserver at $URL Ctrl-C to stop"
	python $GUIDES/http-server.py
fi
