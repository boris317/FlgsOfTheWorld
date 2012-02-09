import re
from xml.parsers import expat

"""
<Placemark>
  <name>Complete Strategist</name>
  <description><![CDATA[]]></description>
  <styleUrl>#style416</styleUrl>
  <Point>
    <coordinates>-71.118881,42.351906,0.000000</coordinates>
  </Point>
</Placemark>
"""
class KmlParser(object):
    def __init__(self):
        self._p = expat.ParserCreate()
        self._p.returns_unicode = True
        self._p.StartElementHandler = self.start_element
        self._p.EndElementHandler = self.end_element
        self._p.CharacterDataHandler = self.char_data
        self.last_element = None
        self.in_item = False
        self.last_cdata = []
        self.stack = []
        self.places = []

    def parse(self, stream):
        self._p.ParseFile(stream)

    #3 handler functions
    def start_element(self, name, attrs):
        name = name.lower()
        if name == "placemark":
            self.places.append({})            
        self.stack.append(name)

    def end_element(self, name):
        name = name.lower()
        self.stack.pop()
        if name == "name" and self.stack[-1] == "placemark":
            self.places[-1]['name'] = self._get_cdata()
        elif name == "description" and self.stack[-1] == "placemark":
            self.places[-1]['description'] = self._get_cdata()
        elif name == "coordinates" and self.stack[-1] == "point":
            self.places[-1]["loc"] = map(float, self._get_cdata().split(",")[:-1])

        self.last_cdata = []
        self.last_element = None

    def char_data(self, data):
        if not self.last_element == 'point':
            data = data.strip()
        self.last_cdata.append(data)

    def _get_cdata(self):
        return ''.join(self.last_cdata)

def parse_kml(filename):
    parser = KmlParser()
    with open(filename, "r") as fp:
        parser.parse(fp)
    return parser.places

def to_mongo_db(places, db_name, collection="places", host='localhost', port=2701):
    from pymongo import Connection, GEO2D
    conn = Connection(host, port)
    db = conn[db_name]
    coll = db[collection]

    coll.insert(places)
    coll.create_index([("loc", GEO2D)])

if __name__ == "__main__":
    import sys
    try:
        host = sys.argv[2]
    except IndexError:
        host = 'localhost'
    try:
        port = int(sys.argv[3])
    except IndexError, TypeError, ValueError:
        port = 27017 
                        
    to_mongo_db(parse_kml(sys.argv[1]), "flgs-stores", collection="stores", host=host, port=port)
    #parse_kml(sys.argv[1])    
