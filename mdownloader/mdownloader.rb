# Base class for all manga downloader
require 'open-uri'
require 'net/http'
 
module MDownloader
    class MangaDownloader
        attr_reader   :domain
        attr_accessor :path_to_download, :manga_name, :manga_volume, :manga_chapter
         
        def initialize(path, manga, vol, chapter)
            @path_to_download = path
            @manga_name       = manga
            @manga_volume     = vol
            @manga_chapter    = chapter
            @domain           = ""
			@agent			  = ""
        end
     
		# Added acess_url call => 02/11
        def self.url_page_exits?(domain, page)
			md = MangaDownloader.new('', '', '', '')
            md.acess_url {Net::HTTP.get(domain, page) != ''}
        end
		
        def get_cover; raise 'This method is abstract.'; end
		
		def get_page_links; raise 'This method is abstract.'; end
		
		# Added return in yield => 01/11
		def acess_url
		    begin
                retries ||= 0
                return yield
            rescue Exception => detail # This is awful and dangerous. Maybe turn back to the previous solution?
                if (retries += 1) < 3 then retry
                else 
					puts("\nNão foi possível baixar esse capítulo. Verifique a conexão e tente novamente. \nDeseja ver a mensagem de erro? S/N")
					if $stdin.gets.chomp.downcase == 's'
						puts(detail)
					end
					exit(true)
                end
            end
		end
		
        def getHtml(page)
            acess_url {return Net::HTTP.get(@domain, page)} # It receives a vector that in each position has a line of the html document  
        end
         
		# Removed page extension => 15/6
		# Added user agend => 16/8
        def download_image(url, page_name) 
			acess_url do
				File.open("#{@path_to_download}\\#{page_name}", 'wb') do |f|
					begin
						# data = acess_url { open("http://#{url}", "User-Agent" => @agent).read }
						# f.write(data)
						f.write(open("http://#{url}", "User-Agent" => @agent).read)
					rescue URI::InvalidURIError
						puts "Não é possível baixar páginas com caracteres não válidos como: \n#{url}\n\n"
						exit(0)
					end
				end
			end
        end
    end
end