import sys
import urllib.request  
from bs4 import BeautifulSoup

# Fetch the html file
#response = urllib.request.urlopen('http://tutorialspoint.com/python/python_overview.htm')
#response = urllib.request.urlopen('http://metroidconstruction.com/hacks.php?sort=&dir=&filters%5B%5D=M1&filters%5B%5D=M2&filters%5B%5D=SM&filters%5B%5D=MF&filters%5B%5D=MZM&filters%5B%5D=MP1&filters%5B%5D=MP2&filters%5B%5D=MP3&filters%5B%5D=Unknown&filters%5B%5D=Boss+Rush&filters%5B%5D=Exploration&filters%5B%5D=Challenge&filters%5B%5D=Spoof&filters%5B%5D=Speedrun%2FRace&filters%5B%5D=Incomplete&filters%5B%5D=Quick+Play&filters%5B%5D=Improvement&filters%5B%5D=Vanilla%2B&search=&num_per_page=1000&source=retropiescript')

#urllib.request.urlretrieve("https://metroidconstruction.com/hacks.php?sort=&dir=&filters%5B%5D=M1&filters%5B%5D=M2&filters%5B%5D=SM&filters%5B%5D=MF&filters%5B%5D=MZM&filters%5B%5D=MP1&filters%5B%5D=MP2&filters%5B%5D=MP3&filters%5B%5D=Unknown&filters%5B%5D=Boss+Rush&filters%5B%5D=Exploration&filters%5B%5D=Challenge&filters%5B%5D=Spoof&filters%5B%5D=Speedrun%2FRace&filters%5B%5D=Incomplete&filters%5B%5D=Quick+Play&filters%5B%5D=Improvement&filters%5B%5D=Vanilla%2B&search=&num_per_page=50&source=retropiescript", filename="/home/pi/metroidconstructionapi/tmp/file.html")

if len(sys.argv) != 3:
    print("Incorrect aguments, needed 2\n- source html file to read\n- output file for data\n\nexample:\npyhton3 parse_html_menu.py file.html output.txt\n")
    exit()

source_html=sys.argv[1]
output_file=sys.argv[2]

response = urllib.request.urlopen('file://' + source_html)
html_doc = response.read()

# Parse the html file
soup = BeautifulSoup(html_doc, 'html.parser')

# Format the parsed html file
#strhtm = soup.html.body.find('tbody').prettify()
description = soup.html.body.find('div', { "class": "underboxB fonttypeA" } ).get_text()
images_div = soup.html.body.find('div', { "class": "underboxE" } )

images = []
if images_div != None:
    images_node = images_div.find_all('img', recursive=False)
    for image_node in images_node:
        #print(image_node)
        images.append(image_node.get('src'))

downloads_div = soup.html.body.find_all('div', { "class": "underboxD" } )

downloads = []
downloads_names = []
if downloads_div != None and len(downloads_div) >= 3:
    #print(downloads_div[2])
    downloads_hyperlinks = downloads_div[2].find_all('a', recursive=False)
    for dh in downloads_hyperlinks:
        link=dh.get('href')
        link=link[link.find('&f=')+3:]
        link=urllib.parse.unquote(link)
        downloads.append(link)
        downloads_names.append(link.get_text())

print("Images Length: " + str(len(images)))
for image in images:
    print(image)

print("Downloads Length: " + str(len(downloads)))
for download in downloads:
    print(download)

if len(images) > 0:
    image=images[0]
if len(downloads) > 0:
    download=downloads[0]
if len(downloads_names) > 0:
    download_name=downloads_names[0]

f = open(output_file, "w")
f.write('hack_image=' + image + "\n")
f.write('hack_image=' + image + "\n")
f.write('hack_images=' + ",".join(images) + "\n")
f.write('hack_download=' + download + "\n")
f.write('hack_download_name=' + download_name + "\n")
f.write('hack_downloads=' + ",".join(downloads) + "\n")
f.write('hack_downloads_names=' + ",".join(downloads_names) + "\n")
f.write('hack_desc=\"' + description + "\"\n")
f.close()