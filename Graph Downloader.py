import os
from urllib2 import urlopen, URLError, HTTPError
import lxml.html

"""
Returns a list of all links at a given url string.
"""
def link_crawler(url):
    connection = urlopen(url)
    
    domain =  lxml.html.fromstring(connection.read())

    url_list = []

    for link in domain.xpath('//a/@href'): # select the url in href for all a tags(links)
        url_list.append(url+link)
    
    return url_list      


"""
Function to download a url.
"""
def dlfile(url):
    # Open the url
    try:
        f = urlopen(url)
        print "downloading " + url

        # Open our local file for writing
        with open(os.path.basename(url), "wb") as local_file:
            local_file.write(f.read())

    #handle errors
    except HTTPError, e:
        print "HTTP Error:", e.code, url
    except URLError, e:
        print "URL Error:", e.reason, url

"""
Download all urls in a url_list.
"""
def dlfiles(url_list):
    
    for url in url_list:
        dlfile(url)
        
def main():
    urls = link_crawler("http://openconnecto.me/data/public/MR/m2g_v1_1_2/SWU4"
    "/sg/JHU/")
    urls.remove(urls[0])
    dlfiles(urls)

if __name__ == '__main__':
    main()
