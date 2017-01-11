#Manga Host Downloader
#by Hermes Passer in 2017-01-10

require 'open-uri'
require 'net/http'

MHDIR = "http://img.mangahost.net/br/mangas_files/"

Shoes.app do

	def url_exits(url_str)
		url = URI.parse(url_str)
	  
		Net::HTTP.start(url.host, url.port) do |http|
			http.head(url.request_uri).code == '200'
		end

		rescue false
	end
	
	def download_image(url, page_name)
		open(page_name, 'wb') do |file|
			file << open(url).read
			#File.rename("#{@page}.jpg", "#{@manga.text} #{@cap.text} 0#{@page}.jpg")
		end
	end
	
	def download_start(manga, capitulo)
	
	end
	
	background "#eee"
    stack :margin => 10 do
		para "manga"
		@manga = edit_line :width => -120
		para "capitulo"
		@cap = edit_line :width => -120
		  
		button "Download", :width => 120 do
			@page = 1
					
			while @page != -1
				if @page < 10
					url = "#{MHDIR}/#{@manga.text}/#{@cap.text}/0#{@page}.jpg"
				else
					url = "#{MHDIR}/#{@manga.text}/#{@cap.text}/#{@page}.jpg"
				end
				
				if (!url_exits(url)) 
					@page = -1
					break;
				end
				
				download_image url, "#{@page}.jpg"

				@page += 1
			end
			
			para "Completed or aborted."
		end
	end
end