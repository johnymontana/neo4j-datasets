# Convert Yelp Data Challenge streaming JSON files into CSV

import json
import csv

YELP_REVIEW_FILE = "../data/yelp_academic_dataset_review.json"
YELP_TIP_FILE = "../data/yelp_academic_dataset_tip.json"
YELP_USER_FILE = "../data/yelp_academic_dataset_user.json"
YELP_CHECKIN_FILE = "../data/yelp_academic_dataset_checkin.json"
YELP_BUSINESS_FILE = "../data/yelp_academic_dataset_business.json"

files = [YELP_REVIEW_FILE, YELP_TIP_FILE, YELP_USER_FILE, YELP_CHECKIN_FILE, YELP_BUSINESS_FILE]

with open(YELP_REVIEW_FILE, "r") as file:
    with open(YELP_REVIEW_FILE + '.csv', 'w') as csvfile:
        writer = csv.writer(csvfile, escapechar='\\', quotechar='"', quoting=csv.QUOTE_ALL)
        writer.writerow(json.loads(file.readline()).keys())
        for line in file:
            l = []
            item = json.loads(line)
            for k,i in item.items():
                # Represent a list of items as a semicolon delimitted string
                if type(i) == list:
                    l.append(';'.join(i))
                # Aggressive quoting and escape char handling
                if type(i) == str:
                    l.append(i.replace('"', '').replace('\\', ''))
                else:
                    l.append(i)
            writer.writerow(l)
