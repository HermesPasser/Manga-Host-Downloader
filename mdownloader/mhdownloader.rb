require_relative 'mdownloader'
require 'net/http'
require 'open-uri'
require 'thread'

module MDownloader
	class Mangahost < MangaDownloader
		
		def initialize(path, manga, chapter)
			super(path, manga, "", chapter)
			@domain 	= "mangashost.com"
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
		
		# Returns the index with an text in the array
		def get_line(array, text)
			array.each { |i| if i.include? text then return i end }
			return nil
		end
		
		def page_links_new_reader(source)
			source = source.split(/\n/)
			pages = []	
			
			# Get the string with the array of <a> tags in <script> tag
			lines = (get_line(source, "var images")).split(/id/)
			
			# Add the first 1 and 2 <a> tags in lines. gsub cause below the tags use simple quotes
			lines.insert(1, get_line(source, "id=\"img_1\"").gsub("\"", "'"))
			lines.insert(2, get_line(source, "id=\"img_2\"").gsub("\"", "'"))
			
			# Get the links
			lines.each do |i|
				if not i.include? @new_patern then next end
				
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
			return pages
		end
		
		def page_links_old_reader(source)
			pages = []
			
			# Get the string with the array of objects in <script> tag
			lines = (get_line(source.split(/\n/), "var pages")).split(/id/)
			
			# Get the links
			lines.each do |i|
				if not i.include? @old_patern then next end
				
				i = i.gsub("\\/", "/")
				i = i[i.index("https:"), i.length].gsub("https://", "")
				i = i[0, i.index("\"}")]
				pages.push(i)
			end
			return pages
		end
		
		# Get a array with manga image links
		def get_page_links
			source = getHtml("/manga/#{@manga_name}/#{@manga_chapter}")
			
			if source.include? "var pages"
				return page_links_old_reader(source)
			elsif source.include? "var images"
				return page_links_new_reader(source)
			else
				puts('Não foi possível baixar esse capítulo. Verifique se escreveu as informações corretamente e se o programa está atualizado.')
				exit(true)
			end
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
					acess_url{download_image(imagelink, path)}
					print("\nDownloaded: #{imagelink} in #{path}")
				}
			end
			
			threads.each(&:join)
			print("\nDownload completo. ")
		end
	end
end