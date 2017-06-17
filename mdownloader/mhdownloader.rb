require_relative 'mdownloader'
require 'net/http'
require 'open-uri'
require 'thread'

module MDownloader
	class Mangahost < MangaDownloader
		
		def initialize(path, manga, chapter)
			super(path, manga, "", chapter)
			@domain 	= "mangahost.me"
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
				if i.include? "#{@name}\\/#{@chapter}\\/"				
					i = i.gsub("\\/", "/")
					i = i[i.index("https:"), i.length].gsub("https://", "")
					i = i[0, i.index("\"}")]
					pages.push(i)
				
				elsif i.include? "#{@name}/#{@chapter}/"				
					i = i.gsub("#{@name}/#{@chapter}/","$")
					i = i.gsub("' alt","*")
					i = i[i.index("$") + 1, i.length]
					i = i[0, i.index("*")]
					pages.push(i)
				end
			end
			return complete_pages(pages)
		end

		def complete_pages(pages)
			unless pages.any? then return -1 end
			
			p = pages[0][pages[0].index("."), pages[0].length] # get page extension		
			s = ""
			
			# if missing some page in the begin, so add it
			while pages[0].to_i > 1
				if pages.count -1 < 10 then s = "0" else s = "" end
				pages.insert(0,"#{s}#{pages[0].to_i - 1}#{p}")
			end
			return pages
		end
		
		# Download all chapters of the manga
		def download_chapter
			webpages = get_page_links
			threads = []
			i = 0	

			ex = webpages[0][webpages[0].rindex("."), webpages[0].length] # get page extension
			# webpages.count -1 < 10 ? s = "0" : s = "" # to add zero before the number
			
			webpages.each do |imagelink| 
				threads << Thread.new{
					i += 1
					download_image(imagelink, "#{@manga_name}_#{@manga_chapter}_#{i.to_s}#{ex}")
					print("\nDownloaded: #{imagelink} in #{@path_to_download}\\#{@manga_name}_#{@manga_chapter}_#{i.to_s}#{ex}")
				}
			end
			
			threads.each(&:join)
			print("\nDownload complete.")
		end	
	end
end