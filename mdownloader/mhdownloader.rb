require_relative 'mdownloader'
require 'net/http'
require 'open-uri'
require 'thread'

module MDownloader
	class Mangahost < MangaDownloader
		
		def initialize(path, manga, chapter)
			super(path, manga, "", chapter)
			@domain = "mangashost.com"
		end
		
		#reimplemented
		def get_cover
			# Does work with shoes
			html = open("https://#{@domain}/manga/#{@manga_name}").read.gsub("<meta property=\"og:image\" content=\"", "~%#").gsub("\"/>", "~").split("~")
			html.each { |line| if line.include?("%#") then print "finish"; return line.gsub("%#", "") end}
		end

		#Override
		def getHtml(page)
            acess_url {return open("http://#{@domain}#{page}").read}
        end

		def complete_pages(pages)
			unless pages.any? then return -1 end
			
			extension = File.extname(pages[0]) 
			s = ""
			
			# if missing some page in the begin, so add it
			while pages[0].to_i > 1
				if pages.count -1 < 10 then s = "0" else s = "" end
				pages.insert(0,"#{s}#{pages[0].to_i - 1}#{extension}")
			end
			return pages
		end
		
		# Cria um vetor com os endereços das pgs
		def get_page_links
			source = getHtml("/manga/#{@manga_name}/#{@manga_chapter}")
			source = source.split(/\n/) 
			lines = Array.new # Receive the lines that save the pages
			pages = Array.new # Receive the pages
				
			source.each do |pos|
				if pos.include? "var pages" or pos.include? "var images"
					lines = pos.split(/id/)
					break;
				end
			end
			
			lines.each do |i|
				if i.include? "#{@manga_name}\\/#{@manga_chapter}\\/"				
					i = i.gsub("\\/", "/")
					i = i[i.index("https:"), i.length].gsub("https://", "")
					i = i[0, i.index("\"}")]
				
				elsif i.include? "#{@manga_name}/#{@manga_chapter}/"
					if i.include? "src='" and i.include? "' alt" 
						indx = i.index("src='") + 5
						i = i[indx, i.index("' alt") - indx]
						i = i.gsub('https://', '')
						pages.push(i)
					else
						puts('Não foi possível baixar esse capítulo. Verifique se escreveu as informações corretamente e se o programa está atualizado.')
						exit(true)
					end	
				end
			end
			return complete_pages(pages)
		end
		
		# Download all chapters of the manga
		def download_chapter
			webpages = acess_url{get_page_links}
			extension = File.extname(webpages[0]) 
			threads = []
			i = 0

			webpages.each do |imagelink| 
				threads << Thread.new{
					i += 1
					path = "#{@manga_name}_#{@manga_chapter}_#{i.to_s}#{extension}"
					download_image(imagelink, path)
					print("\nDownloaded: #{imagelink} in #{path}")
				}
			end
			
			threads.each(&:join)
			print("\nDownload complete.")
		end	
	end
end