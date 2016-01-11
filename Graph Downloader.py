import os
from urllib2 import urlopen, URLError, HTTPError
import lxml.html
from graphml2mat import graphml2mat

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
Function to download a url in a web directory.
"""
def dlfile(directory, url):
    # Open the url
    try:
        f = urlopen(url)
        print "downloading " + url

        # Open our local file for writing
        with open(os.path.basename(url), "wb") as local_file:
            local_file.write(f.read())
        f.close()
        url = url.replace(directory,"")
        url2 = url.replace("graphml","mat")
        graphml2mat(url, url2)

    #handle errors
    except HTTPError, e:
        print "HTTP Error:", e.code, url
    except URLError, e:
        print "URL Error:", e.reason, url

"""
Download all urls in a url_list from a web directory.
"""
def dlfiles(directory, url_list):
    
    for url in url_list:
        dlfile(directory, url)
        
def main():
    directory = "http://openconnecto.me/data/public/MR/m2g_v1_1_2/SWU4/sg/JHU/"
    urls = link_crawler(directory)
    urls.remove(urls[0])
    dlfiles(directory, urls)

if __name__ == '__main__':
    main()