food_truck
==========

A service that tells the user what types of food trucks might be found near a specific location on a map.
A demo version is hosted at http://146.148.41.202:8887/static/index.html

### Overview

* Features
* Codebase overview
* Setup
    * Data loading.
    * Starting server.
    * Running unitest.
* Development
* Improvements

### Features
* A the landing page the user two option to find food trucks in a specific location
    1. The user could directly click on a location on the map.
    2. The user can choose to click on one of the suggested locations. (for ex. "Financial District")
In both the scenarios, the app will behave as follows
Firstly, zoom down to the location.
Secondly, drop markers for food trucks found around that area.
Finally will render records for each food truck in the left search result listings section.

* Markers have alphabetically label to correspond to records in the listing sections.
* Clicking on the address on the record in the listing section, will animate it's coresponding marker.

### Codebase overview
The codebase mainly consists of
* App code in `src\app.coffee` and `index.html`
* Server code in `server.py` and it's unitest in `api_test.py`
* Finally the code `data\data_engineering.py` and `data\sql_orm.py` that is used to transform/engineer the data and load it into mysql sqlAlchamey ORM.


### Setup
* the setup involves primarily going through ./setup.sh
    ** Data loading.
    ```
        # setup db
        python data/sql_orm.py
        # load data
        cd data
        python data_engineering.py
    ```
    ** Starting server.
    ```
    ./run_server.sh
    ```

    ** Running unitest.
    ```
    ./test_runnner.sh
    ```

### Development
Grunt is used to compiling `src\app.coffee` into `js/index.js`
```
grunt watch
```
on saving a .coffee file grunt compiles coffescript into javascript.

### Improvements
* Ansible scriptsfor automation around setup
* User should be able to control the serach radius around a user specified location.
* Identify and remove duplicate food trucks in same location with the same ownership.
* use grunt to minify the compiled js.
* Add ability to narrow down to a location using a search inplimentation.


