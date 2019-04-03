import sqlalchemy
from sqlalchemy import create_engine,func,desc,inspect,distinct
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from flask import Flask,jsonify,request,render_template
import numpy as np
import datetime as dt
from datetime import datetime

#initating the engine
engine=create_engine("sqlite:///hawaii.sqlite")

# reflect using the orm & save the reference to the tables
Base=automap_base()
Base.prepare(engine,reflect=True)
print(Base.classes.keys())
Measurement=Base.classes.measurement
Station=Base.classes.station

session =Session(engine)
    # create a list of stations
sel=[distinct(Measurement.station),Station.name]
stations_list=session.query(*sel).filter(Measurement.station==Station.station).all()
    #creating dict of stations with station id and names
stations_list_dict=map(dict,stations_list)

print(stations_list_dict)


# initating app
app = Flask(__name__)

@app.route("/")
def home():
    #create a session with the engine
    session =Session(engine)
    return render_template("home.html",framework='flask')
    
@app.route("/api/v1.0/precipitation")
def preci_data():
    #create a session with the engine
    session =Session(engine)
    # create query with date and precipitation for last 1 yr
    sel=[Measurement.date,Measurement.prcp.label("precipitation")]
    query_date=dt.date(2017,8,23)-dt.timedelta(days=365)
    prcp_list_1=session.query(*sel).filter(Measurement.date  >= query_date).order_by(Measurement.date).all()
    #create new list of dict with date as key and precip as val
    prcp_list=[]
    for row_dt,row_prcp in prcp_list_1:
        prcp_dict={}
        prcp_dict[row_dt]=row_prcp
        prcp_list.append(prcp_dict)
       
    return jsonify({"precipitation":prcp_list})

@app.route("/api/v1.0/stations")
def station_list():
    #create a session with the engine
    session =Session(engine)
    # create a list of stations
    sel=[distinct(Measurement.station),Station.name]
    stations_list=session.query(*sel).filter(Measurement.station==Station.station).all()
    #creating dict of stations with station id and names
    stations_list_dict=dict(stations_list)
    return jsonify({"stations":stations_list_dict})
   

@app.route("/api/v1.0/tobs")
def temp_listing():
    #create a session with the engine
    session =Session(engine)
    # create a list of temp & date for the previous year
    sel=[Measurement.date,Measurement.tobs]
    # get the start date(previous 1 yr) from the latest date calculated in jupyter
    query_date=dt.date(2017,8,23)-dt.timedelta(days=365)
    temp_list_1=session.query(*sel).filter(Measurement.date  >= query_date).order_by(Measurement.date).all()
    temp_list=[]
    for row_dt,row_temp in temp_list_1:
        temp_dict={}
        temp_dict[row_dt]=row_temp
        temp_list.append(temp_dict)
    return jsonify({"temperature":temp_list})

@app.route("/api/v1.0/<start>")
@app.route("/api/v1.0/<start>/<end>")
def agg_start_list(start=None,end=None):
    #create a session with the engine
    session =Session(engine)
    #Data for tmin,tavg,tmax vals
    sel=[func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)]
    def get_date(date1):
        year, month, day = map(int, date1.split('-'))
        converted_to_date= datetime(year, month, day)
        return converted_to_date
    # check if start date and end end are provided or not
    if start is not None and end is not None:
        start_date=get_date(start)
        end_date =get_date(end)
        agg_list=session.query(*sel).filter(Measurement.date >= start_date).filter(Measurement.date <= end_date).all()
    elif start is not None and end is None:
        start_date=get_date(start)
        agg_list=session.query(*sel).filter(Measurement.date >= start_date).all()
    new_agg=np.ravel(agg_list)   
    return jsonify({"min":new_agg[0],"avg":new_agg[1],"max":new_agg[2]})


if __name__=="__main__":
    app.run(debug=True)