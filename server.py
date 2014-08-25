"""
tornado web server
Implement a REST server that returns suggestions and movies
"""

import json
import logging
from operator import itemgetter

from elasticsearch import Elasticsearch
import Levenshtein
import tornado.ioloop
import tornado.web
import tornado.gen


from data.sql_orm import MobileFoodFacility
from data.sql_orm import session


LOG_FORMAT = '%(asctime)s - %(filename)s:%(lineno)s - %(levelname)s - %(message)s'
logging.basicConfig(format=LOG_FORMAT, level=logging.INFO)


class BaseRequestHandler(tornado.web.RequestHandler):
    """Base Handler with capabiblity to write json data back"""

    @property
    def session(self):
        """sql orm session property from the main application object is referenced"""
        if not hasattr(self, '_session'):
            self._session = self.application.session

        return self._session

    def json_write(self, data, field='data'):
        """Given a python dict wraps it in a data attribute and returned."""
        self.set_header(name="Content-Type", value="application/json")
        self.write(json.dumps({field: data}))
        self.finish()

@tornado.gen.coroutine
def search(session, latitude, longitude):
    min_latitude = latitude - 0.005
    max_latitude = latitude + 0.005

    min_longitude = longitude - 0.005
    max_longitude = longitude + 0.005
    records = session.query(MobileFoodFacility).\
        filter(MobileFoodFacility.latitude<=max_latitude).\
        filter(MobileFoodFacility.latitude>=min_latitude).\
        filter(MobileFoodFacility.longitude<=max_longitude).\
        filter(MobileFoodFacility.longitude>=min_longitude)

    search_results = []
    letter_ord = ord('A')
    for record in records[:26]:
        search_result = record.to_json()
        search_result['letter'] = chr(letter_ord)
        letter_ord += 1
        search_results.append(search_result)
    # logging.info("Got %d Hits for %s", res['hits']['total'], query)
    # search_results = [hit["_source"] for hit in res['hits']['hits']]
    print len(search_results)
    raise tornado.gen.Return(search_results)

class FacilityRequestHandler(BaseRequestHandler):
    """
    """

    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self, query):
        """
        """
        latitude = self.get_argument('latitude', default='37.758895')
        longitude = self.get_argument('longitude', default='-122.41472420000002')
        latitude = float(latitude)
        longitude = float(longitude)
        print latitude, longitude

        search_results = yield search(self.session, latitude, longitude)
        self.json_write(search_results, 'facilities')

class App(tornado.web.Application):
    """Main app suggestions singleton is an attribute of this object."""
    handlers = [
        (r"/facility/*([a-zA-Z0-9-]*)", FacilityRequestHandler),
        (r'/static/(.*)', tornado.web.StaticFileHandler, {'path': './'}),
    ]

    def __init__(self):
        tornado.web.Application.__init__(self, self.handlers, debug=True)

    @property
    def suggestions(self):
        """intantiates the list of suggestions."""
        if not hasattr(self, '_suggestions'):
            suggestions = [str(word).lower() for word in json.loads(words)]
            self._suggestions = suggestions

        return self._suggestions

    @property
    def session(self):
        """intantiates a connection to sql orm"""
        if not hasattr(self, '_session'):
            self._session = session

        return self._session


if __name__ == "__main__":
    application = App()
    application.listen(8887)
    tornado.ioloop.IOLoop.instance().start()

