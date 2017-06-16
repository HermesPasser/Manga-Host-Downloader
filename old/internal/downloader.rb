#Manga Host Downloader by Hermes Passer in 2017-03-20

require 'open-uri'

MHDIR = "http://img.mangahost.net/br/mangas_files/"

class Downloader

	def initialize(url, page_name)
		download_image(url, page_name)
	end
	
	private def url_exits(url_str)
		
		begin
			retries ||= 0
			url = URI.parse(url_str)
		rescue Exception => e
			if (retries += 1) < 3 then retry
			else
				putslog("Não foi possível estabelecer uma conexão com o servidor.")
				return -1;
			end
		end
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
		
		# if (url_exits(url))
			open(page_name, 'wb') do |file|
				file << open(url).read
			end
			putslog("baixado: #{url}.")
		# end
		# puts "#{url}     #{page_name}"
	end
end