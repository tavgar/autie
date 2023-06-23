#!/bin/bash

# Ask the user for a domain name
read -p "Enter a domain name: " domain

# Create a subdomains.txt file to store the subdomains
touch subdomains.txt

# Use subfinder to get the subdomains of the domain
subfinder -d $domain | sort | uniq > subdomains.txt

# Use subscraper to get more subdomains and append them to subdomains.txt
#subscraper -d $domain | sort | uniq >> subdomains.txt
echo 'subfinder finished'
# Use amass to get more subdomains and append them to subdomains.txt
amass enum -d $domain | sort | uniq >> subdomains.txt

# Use sublist3r to get more subdomains and append them to subdomains.txt
sublist3r -d $domain | sort | uniq >> subdomains.txt

# Use assetfinder to get more subdomains and append them to subdomains.txt
assetfinder -subs-only $domain | sort | uniq >> subdomains.txt

# Use subzy to check for subdomain takeovers and save the result as takeover.txt
./$home_dir/subzy/subzy -t $domain > takeover.txt

# Use httpx to filter the live subdomains and save them as live.txt
httpx -silent -timeout 5s -threads 100 -status-code -o live.txt -i subdomains.txt

# Use waybackurls and gau to get all URLs of the domain and save them as urls.txt
cat live.txt | waybackurls | gau | sort | uniq > urls.txt

katana -list live.txt | gau | sort | uniq >> urls.txt

python $home_dir/ParamSpider/paramspider.py -d $domain | gau | sort | uniq >> urls.txt

# Use nuclei to scan for vulnerabilities of the live subdomains and save the result as nuclei.txt
nuclei -silent -timeout 5s -threads 100 -o nuclei.txt -i urls.txt  -t "$home_dir/fuzzing-templates" -rl 05

# Use dalfox to check for XSS in the URLs and save the result as xss.txt
dalfox run -silent -o xss.txt urls.txt

# Use sqlmap to check for SQL injection in the URLs and save the result as sqli.txt
sqlmap -silent -o sqli.txt -i urls.txt

# Use oralyzer to check for open redirects and save the result as redirects.txt
python $home_dir/Oralyzer/oralyzer.py run -silent -o redirects.txt urls.txt
