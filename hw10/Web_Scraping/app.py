from flask import Flask, render_template, redirect
from flask_pymongo import PyMongo
import scrape_mars

# Create an instance of Flask
app = Flask(__name__)

# Use PyMongo to establish Mongo connection
mongo = PyMongo(app, uri="mongodb://localhost:27017/mars_app")


@app.route("/")
def index():
    mdatadict = mongo.db.marsdata.find_one()
    mdatadict.pop('_id', None)
    mkeylist = list(mdatadict)
    return render_template("index.html", marsdata=mdatadict, marskeys=mkeylist)


@app.route("/scrape")
def scraper():
    marsdata = mongo.db.marsdata
    newmarsdata = scrape_mars.scrape()
    marsdata.update({}, newmarsdata, upsert=True)
    return redirect("/", code=302)


if __name__ == "__main__":
    app.run(debug=True)
