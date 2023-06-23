#!/bin/bash

# Ask the user for a domain name
read -p "Enter a domain name: " domain
home_dir=$(eval echo ~$USER)
# Create a subdomains.txt file to store the subdomains
touch subdomains.txt


# Use sublist3r to get more subdomains and append them to subdomains.txt
sublist3r -d $domain -o subdomains.txt
echo 'sublist3r finished'
# Use subfinder to get the subdomains of the domain
subfinder -d $domain | sort | uniq >> subdomains.txt

# Use subscraper to get more subdomains and append them to subdomains.txt
#subscraper -d $domain | sort | uniq >> subdomains.txt
echo 'subfinder finished'
# Use amass to get more subdomains and append them to subdomains.txt
amass enum -d $domain | sort | uniq >> subdomains.txt
echo 'amass finished'
# Use assetfinder to get more subdomains and append them to subdomains.txt
assetfinder -subs-only $domain | sort | uniq >> subdomains.txt
echo 'assertfinder finished'
# Use subzy to check for subdomain takeovers and save the result as takeover.txt
./$home_dir/subzy/subzy -t $domain > takeover.txt
echo 'subzy finished'
# Use httpx to filter the live subdomains and save them as live.txt
httpx -silent -timeout 30 -threads 100 -o live.txt -l subdomains.txt
echo 'httpx finished'
python $home_dir/JsFinders/JSFinder.py -f live.txt --deep --js -ou urls.txt
echo 'Jsfinder done'
# Use waybackurls and gau to get all URLs of the domain and save them as urls.txt
cat live.txt | waybackurls | sort | uniq >> urls.txt
echo 'waybackurls finished'
cat live.txt | gau | sort | uniq >> urls.txt
echo 'gau done!'
katana -list live.txt | sort | uniq >> urls.txt
echo 'katana finished'
python $home_dir/ParamSpider/paramspider.py -d $domain --level high | sort | uniq >> urls.txt
echo 'ParamSpider finished'
#url filteration
grep "$domain" urls.txt > temp.txt && mv temp.txt urls.txt
# Use nuclei to scan for vulnerabilities of the live subdomains and save the result as nuclei.txt
nuclei -silent -timeout 20 -o nuclei.txt -l urls.txt  -t "$home_dir/fuzzing-templates" -rl 05
echo 'Nuclei finished'
# Use dalfox to check for XSS in the URLs and save the result as xss.txt
dalfox -o xss.txt file urls.txt
echo 'Dalfox finished'
# Use sqlmap to check for SQL injection in the URLs and save the result as sqli.txt
sqlmap -silent -o sqli.txt -l urls.txt
echo 'SqlMap finished'
# Use oralyzer to check for open redirects and save the result as redirects.txt
python $home_dir/Oralyzer/oralyzer.py -l urls > redirects.txt
echo 'Done!'
