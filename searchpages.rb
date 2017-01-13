#Manga Host Downloader by Hermes Passer in 2017-01-13
require 'net/http'

class Pages

	def initialize(name, chapter)  
		@name = name
		@chapter = chapter
		get_pages
	end 
  
	public def get_pages
		# It receives a vector that in each position has a line of the html document
		source = Net::HTTP.get('mangahost.net', "/manga/#{@name}/#{@chapter}")
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
				i = i.gsub("#{@name}\\/#{@chapter}\\/","$")
				i = i.gsub("\"}","*")
				i = i[i.index("$") + 1, i.length]
				i = i[0, i.index("*")]
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

	private def complete_pages(pages)
		p = pages[0][pages[0].index("."), pages[0].length] # get page extension
		s = ""
		
		# if missing some page in the begin, so add him
		while pages[0].to_i > 1
			if pages.count -1 < 10 then s = "0" else s = "" end
			pages.insert(0,"#{s}#{pages[0].to_i - 1}#{p}")
		end
		return pages
	end
end