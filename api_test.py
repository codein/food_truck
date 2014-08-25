"""
Test constitutes

* test facility end point
"""


import requests
import json
import shutil
import httplib
import unittest

class TestSequenceFunctions(unittest.TestCase):
    """container to hold different test scenarios."""
    def setUp(self):
        self.base_url = 'http://localhost:8887'

    def _get_url(self, path):
        """given a relative path, return full url"""
        return '%s/%s' % (self.base_url, path)

    def test_default_search(self):
        """
        Tests the facility search
        Ensure the record contain all require attributes.
        """
        json_attributes = [
            'applicant',
            'facilitytype',
            'fooditems',
            'latitude',
            'longitude',
            'address',
            'schedule',
            'status',
            'locationdescription',
        ]

        data = self.get('facility?latitude=37.758895&longitude=-122.41472420000002')
        self.assertTrue(len(data['facilities']) > 0)
        facility_record = data['facilities'][0]

        for attribute in json_attributes:
            self.assertTrue(attribute in facility_record)

    def _loads_response(self, response):
        """given a response object json.loads the data and return."""
        if response.status_code == httplib.OK:
            return json.loads(response.text)

    def get(self, path, data=None):
        """helper to make GET requests"""
        url = self._get_url(path)
        response = requests.get(url)
        return self._loads_response(response)


if __name__ == '__main__':
    unittest.main()