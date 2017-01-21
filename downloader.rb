#Manga Host Downloader by Hermes Passer in 2017-01-13

require 'open-uri'
require 'net/http'

MHDIR = "http://img.mangahost.net/br/mangas_files/"

class Downloader

	def initialize(url, page_name)
		download_image(url, page_name)
	end
	
	private def url_exits(url_str)
		url = URI.parse(url_str)
	  
		Net::HTTP.start(url.host, url.port) do |http|
			http.head(url.request_uri).code == '200'
		end
		#rescue TypeError
		rescue false
	end

	private def download_image(url, page_name)
		unless (url_exits(url))
			url = url.gsub("mangas_files","images")
		end
		
		if (url_exits(url))
			open(page_name, 'wb') do |file|
				file << open(url).read
			end
			puts("baixado: #{url}.")
		end
	end
end