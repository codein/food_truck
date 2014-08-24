"""
Script to enginner the raw csv data
1.

usage
python data_engineering.py
"""

import csv
import json
import logging

from pprint import pprint

from sql_orm import MobileFoodFacility
from sql_orm import session

LOG_FORMAT = '%(asctime)s - %(filename)s:%(lineno)s - %(levelname)s - %(message)s'
logging.basicConfig(format=LOG_FORMAT, level=logging.INFO)
FILE_NAME = 'Mobile_Food_Facility_Permit test.csv'
FILE_NAME = 'Mobile_Food_Facility_Permit.csv'
OUT_FILE_NAME = 'Mobile_Food_Facility_Permit.py'

"""
1. Reads records from .csv
2. Retrieves latitude and longitude for each locations
3. Finally writes the data into .py file

for ex a final record for a mobile food facility is as follows
{'address': '50 01ST ST',
 'applicant': 'Cupkates Bakery, LLC',
 'approved': '06/02/2014 03:32:00 PM',
 'block': '3708',
 'blocklot': '3708055',
 'cnn': '101000',
 'expirationdate': '03/15/2015 12:00:00 AM',
 'facilitytype': 'Truck',
 'fooditems': 'Cupcakes',
 'id': 1,
 'latitude': '37.7901490737255',
 'location': '(37.7901490874965, -122.398658184594)',
 'locationdescription': '01ST ST: STEVENSON ST to JESSIE ST (21 - 56)',
 'locationid': '546631',
 'longitude': '-122.398658184604',
 'lot': '055',
 'noisent': '',
 'permit': '14MFF-0102',
 'priorpermit': '0',
 'received': 'Jun  2 2014 12:23PM',
 'schedule': 'http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=14MFF-0102&ExportPDF=1&Filename=14MFF-0102_schedule.pdf',
 'status': 'APPROVED',
 'x': '6013063.33',
 'y': '2115738.283'}
"""

with open(FILE_NAME, 'rb') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',')
    headers = []
    records = []
    errors = 0
    for row_no,row in enumerate(spamreader):
        if row_no == 0:
            headers = [header.lower().replace(' ', '_') for header in row]
        else:
            record = {'id': row_no}
            for column_no, column_value in enumerate(row):
                column_name = headers[column_no]
                record[column_name] = column_value

            records.append(record)
            if row_no % 20 == 0:
                print row_no

            try:
                mobile_food_facility = MobileFoodFacility(**record)
                session.add(mobile_food_facility)
                session.commit()
            except ValueError:
                errors += 1
                logging.error('Error creating %d', record['id'])

            length = len(mobile_food_facility.fooditems)


    print len(records), 'records found with', errors, 'errors'


