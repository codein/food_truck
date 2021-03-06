"""
ORM definition
Script to create persistance tables in mysql
"""

from sqlalchemy import Column
from sqlalchemy import create_engine
from sqlalchemy import Float
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

engine = create_engine('mysql://robin:varghese@localhost:3306/food_truck_db', echo=False)
Session = sessionmaker(bind=engine)
session = Session()
Base = declarative_base()


class MobileFoodFacility(Base):
    """ORM for out facility/food truck object"""
    __tablename__ = 'mobile_food_facility'

    id = Column(Integer, primary_key=True)
    address = Column(String(100))
    applicant = Column(String(100))
    approved = Column(String(100))
    block = Column(String(100))
    blocklot = Column(String(100))
    cnn = Column(String(100))
    expirationdate = Column(String(100))
    facilitytype = Column(String(100))
    fooditems = Column(String(500))
    latitude = Column(Float)
    location = Column(Float)
    locationdescription = Column(String(100))
    locationid = Column(String(100))
    longitude = Column(String(100))
    lot = Column(String(100))
    noisent = Column(String(100))
    permit = Column(String(100))
    priorpermit = Column(String(100))
    received = Column(String(100))
    schedule = Column(String(500))
    status = Column(String(100))
    x = Column(String(100))
    y = Column(String(100))

    # json serializer fields
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

    def __init__(self, **kwargs):
        if kwargs is not None:
            for key, value in kwargs.iteritems():
                if key in ['latitude', 'longitude']:
                    value = float(value)

                setattr(self, key, value)

    def __repr__(self):
        """string"""
        return "<MobileFoodFacility(%d, %s, %s, %s, %s)>" % (self.id,
                                                  self.applicant,
                                                  self.facilitytype,
                                                  self.latitude,
                                                  self.longitude)

    def to_json(self):
        """json serializer"""
        record = {}
        for attribute in self.json_attributes:
            record[attribute] = getattr(self, attribute)

        return record


if __name__ == "__main__":
    # script to create tables in mysql
    Base.metadata.create_all(engine)