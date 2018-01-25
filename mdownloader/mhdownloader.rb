require_relative 'mdownloader'
require 'net/http'
require 'open-uri'
require 'thread'

module MDownloader
	class Mangahost < MangaDownloader
		
		def initialize(path, manga, chapter)
			super(path, manga, "", chapter)
			@domain 	= "mangahost.cc"
			@old_patern = "#{@manga_name}\\/#{@manga_chapter}\\/"
			@new_patern = "#{@manga_name}/#{@manga_chapter}/"
		end
		
		#reimplemented
		def get_cover
			# Doesn't work with shoes
			html = open("https://#{@domain}/manga/#{@manga_name}").read.gsub("<meta property=\"og:image\" content=\"", "~%#").gsub("\"/>", "~").split("~")
			html.each { |line| if line.include?("%#") then print "finish"; return line.gsub("%#", "") end}
		end

		#Override
		def getHtml(page)
            acess_url {return open("http://#{@domain}#{page}").read}
        end
		
		# Get a array with manga image links
		def get_page_links
			pages = []
			source = getHtml("/manga/#{@manga_name}/#{@manga_chapter}")
			
			# Get the links in <script> tag
			source = source.match(/(pages = |images = ).*(?<=\])/).to_s
			source = source.scan(/(?=src='|"url\":\")(.*?)(images|mangas_files)(.*?)(?<='|")/)
			source.each do |page| # Não to pegrando o do pag mas aparentemente ta funcionando mesmo assim
				page = page[0] + page[1] + page[2]
				page = page.gsub("src=", '').gsub("'", '')
				page = page.gsub("\"url\":\"", '').gsub("\"", '')
				page = page.gsub("\\/", '/').gsub("https://", '')#
				pages.push(page)
			end
			
			return pages
		end
		
		# Download all chapters of the manga
		def download_chapter
			webpages = acess_url{get_page_links}			
			
			# extension = File.extname(webpages[0]) # to rename each page with a default name
			threads = []
			i = 0
			
			# In the future, add a token to swich the save mode of with default name to the original name and vice versa
			webpages.each do |imagelink| 
				threads << Thread.new{
					# To save with a default name of the file
					# i += 1
					# path = "#{@manga_name}_#{@manga_chapter}_#{i.to_s}#{extension}"
					
					# To save with the original name of the file
					path = File.basename(imagelink)
					
					acess_url{download_image(imagelink, path)}
					print("\nDownloaded: #{imagelink} in #{path}")
				}
			end
			
			threads.each(&:join)
			print("\nDownload completo.")
		end
	end
end