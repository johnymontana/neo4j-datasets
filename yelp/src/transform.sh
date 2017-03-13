# create CSV for reviews
#cat ../data/yelp_academic_dataset_review.json | jq -s '.' | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' > ../data/review.csv

# convert streaming json files to standard json
declare -a arr=("review" "checkin" "user" "tip" "business")

for i in "${arr[@]}"
do
	echo "$i"
	cat ../data/yelp_academic_dataset_$i.json | jq -s '.' > ../data/$i.json
done
