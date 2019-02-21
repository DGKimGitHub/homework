# Import BeautifulSoup
from bs4 import BeautifulSoup as bs
import pandas as pd
import time
# Import Splinter and set the chromedriver path
from splinter import Browser

sleeptime = 0.3


def init_browser():
    '''
    Instantiate the browser
    '''
    executable_path = {"executable_path": "./chromedriver"}
    return Browser("chrome", **executable_path, headless=False)
# def init_browser()


def visit_scrape_soup(b, url):
    '''
    Visit the url and scrape into soup
    '''
    b.visit(url)
    time.sleep(sleeptime)
    # Scrape the browser into soup
    html = b.html
    return bs(html, 'lxml')
# def visit_scrape_soup(b, url)


def scrape_news(brwsr):
    '''
    NASA Mars News:
    Scrape the [NASA Mars News Site](https://mars.nasa.gov/news/) and collect the latest News Title and Paragraph Text.
    '''
    # Visit the URL and scrape
    mnewsurl = "https://mars.nasa.gov/news/"
    nsoup = visit_scrape_soup(brwsr, mnewsurl)

    # Find the first news title and paragraph
    news = nsoup.find("li", class_="slide")
    ndict = dict()
    ndict["title"] = news.find('div', class_='content_title').text
    ndict["para"] = news.find('div', class_='rollover_description_inner').text

    return ndict
# def scrape_news(brwsr)


def scrape_fimg(brwsr):
    '''
    JPL Mars Space Images - Featured Image:
    Visit the url for JPL Featured Space Image and
    find the image url for the current Featured Mars Image.
    '''
    jplurl = "https://www.jpl.nasa.gov"
    # Visit the URL and scrape
    img_search_url = f"{jplurl}/spaceimages/?search=&category=Mars"
    imgsoup = visit_scrape_soup(brwsr, img_search_url)

    # Find path to wallpaper size image of the current Featured Mars Image
    imgitem = imgsoup.find("article", class_="carousel_item")
    imgpath = imgitem['style'].split("'")[1]
    imgurl = f"{jplurl}{imgpath}"

    return imgurl
# def scrape_fimg(brwsr)


def scrape_weather(brwsr):
    '''
    Mars Weather:
    Visit the Mars Weather twitter account and
    scrape the latest Mars weather tweet from the page.
    '''
    # Visit the URL and scrape
    wurl = "https://twitter.com/marswxreport?lang=en"
    wsoup = visit_scrape_soup(brwsr, wurl)

    # Get list of tweets
    tlist = wsoup.find_all("li", class_="js-stream-item")
    wtext = None
    wkeywords = {'Sol', 'pressure', 'daylight'}

    # Loop through and find the most recent weather tweet
    for t in tlist:
        if t.div["data-screen-name"] == "MarsWxReport":
            mwtext = t.find(class_="tweet-text").a.previousSibling
            if wkeywords.issubset(set(mwtext.split())):
                wtext = mwtext
                break

    return wtext
# def scrape_weather(brwsr)


def scrape_facts(brwsr):
    '''
    Mars Facts:
    Visit the Mars Facts webpage and
    use Pandas to scrape the table containing facts about the planet including Diameter, Mass, etc.
    '''
    # Use Panda's `read_html` to parse the url
    furl = "http://space-facts.com/mars/"
    ftables = pd.read_html(furl)

    # Get the table dataframe and update column names
    fdf = ftables[0]
    fdf.columns = ['Parameter', 'Value']

    # Use to_html to generate HTML tables from dataframe.
    fhtml = fdf.to_html(index=False,
                        justify="center",
                        classes="table table-striped table-hover table-dark table-bordered table-sm")

    # Strip unwanted newlines to clean up the table.
    fhtml = fhtml.replace('\n', '')

    return fhtml
# def scrape_facts(brwsr)


def scrape_hemisphere(b, num):
    '''
    Mars Hemispheres:
    Visit the USGS Astrogeology site to obtain high resolution images for the requested Mars hemisphere.
    '''
    # Design an XPATH selector to grab the hemisphere images
    xpath = '//div[@class="collapsible results"]/div[@class="item"]/a/img'

    # Find links to hemisphere image thumbnails and click on the requested one
    hresults = b.find_by_xpath(xpath)
    hresults[num].click()
    time.sleep(sleeptime)

    # Scrape the browser into soup
    html = b.html
    soup = bs(html, 'lxml')

    # Save title and url in dict
    imgdict = dict()
    imgdict["title"] = soup.find(
        "h2", class_="title").text.strip("Enhanced").strip()
    imgdict["url"] = soup.find("div", class_="downloads").ul.li.a["href"]

    # Go back to previous page
    b.back()

    return imgdict
# def scrape_hemisphere(b, num)


def scrape_all_hemispheres(brwsr):
    '''
    Mars Hemispheres:
    Visit the USGS Astrogeology site to obtain high resolution images for each of Mar's hemispheres.
    '''
    # Visit the URL
    hurl = "https://astrogeology.usgs.gov/search/results?q=hemisphere+enhanced&k1=target&v1=Mars"
    brwsr.visit(hurl)
    time.sleep(sleeptime)

    # list of dicts to save results
    himglist = list()
    hnum = 0
    while hnum < 4:
        himglist.append(scrape_hemisphere(brwsr, hnum))
        hnum += 1

    return himglist
# def scrape_all_hemispheres(brwsr)


def scrape():
    '''
    Scrapes various websites for data related to the Mission to Mars and
    return one Python dictionary containing all of the scraped data.
    '''
    browser = init_browser()

    results = dict()
    results["Latest Mars News"] = scrape_news(browser)
    results["Featured Mars Image"] = scrape_fimg(browser)
    results["Current Weather on Mars"] = scrape_weather(browser)
    results["Mars Facts"] = scrape_facts(browser)
    results["Mars Hemispheres"] = scrape_all_hemispheres(browser)

    # Close the browser after scraping
    browser.quit()

    return results
# def scrape()

# print(scrape())
