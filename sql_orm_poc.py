from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String

engine = create_engine('mysql://robin:varghese@localhost:3306/food_truck_db', echo=False)

Session = sessionmaker(bind=engine)
session = Session()



Base = declarative_base()
class MyTable(Base):
    __tablename__ = 'mytable'

    id = Column(Integer, primary_key=True)
    name = Column(String(100))
    value = Column(String(100))

    def __init__(self, name, value):
            self.name = name
            self.value = value

    def __repr__(self):
            return "<MyTable(%s, %s)>" % (self.name, self.value)

# Base.metadata.create_all(engine)

new_record = MyTable('Genius', 'me')
session.add(new_record)
# session.commit()


list_of_records = [MyTable('Genius', 'me'), MyTable('Super', 'me')]
session.add_all(list_of_records)
# session.commit()


records = session.query(MyTable).filter_by(name='Genius')

for record in records:
    print record.name, record.value


def poc(**kwargs):
    print kwargs

points = {'x':1, 'y':2}
poc(**points)