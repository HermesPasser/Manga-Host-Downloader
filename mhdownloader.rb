#Manga Host Downloader
#by Hermes Passer in 2017-01-10

load 'searchpages.rb'
load 'downloader.rb'
require 'fileutils'

def rename_files(manga, chapter, arry)
	FileUtils.mkdir_p("mangas/#{manga}/#{chapter}")

	i = 0
	while i < arry.length		
		File.rename(arry[i], "#{manga} c#{chapter} p#{arry[i]}")
		puts("renomeando arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}.")
		
		FileUtils.mv("#{manga} c#{chapter} p#{arry[i]}", "mangas/#{manga}/#{chapter}")
		puts("movendo #{manga} c#{chapter} p#{arry[i]} para mangas/#{manga}/#{chapter}.")
		i += 1
	end
end

def download_one(manga, chapter)
	pages = Pages.new(manga, chapter).get_pages
	@arry = Array.new
	
	pages.each do |page|
		url = "#{MHDIR}/#{manga}/#{chapter}/#{page}"
		Downloader.new(url, page)
		puts("baixado: #{MHDIR}/#{manga}/#{chapter}/#{page}.")
	end
	
	rename_files(manga, chapter, pages)
end

def download_multiple(manga, init_chapter, end_chapter)

end

puts("\n\n\t\tManga Host Downloader 0.1\n\tpor Hermes Passer - gladiocitrico.blogspot.com")
loop = true

while loop
	puts("\tO que deseja fazer? \n\t\t1 - baixar um capítulo\n\t\t3 - notas\n\t\t4 - sair\n\n") #\n\t\t2 - baixar varios capitulos
	input = gets.chomp!
	if input == "1"
		puts("Digite o nome do manga exatamente como está no mangahost:")
		manga = gets.chomp!
		puts("Digite numero do capitulo:")
		chapter = gets.chomp!
		
		if (manga == "" || chapter == "")
			puts("Os campos nao devem estar em branco:")
			next
		end

		download_one(manga.downcase.gsub(" ","-").strip, chapter)
	elsif input == "2"

	elsif input == "3"
		puts("\n\nManga Host Downloader 0.5\nPor Hermes Passer - gladiocitrico.blogspot.com")
	elsif input == "4"
		loop = false
	end
end

=begin
def download_by_index(manga, chapter)
	@page = 1, @arry = Array.new
	while @page != -1
		if @page < 10 url = "#{MHDIR}/#{manga}/#{chapter}/0#{@page}.jpg"
		else url = "#{MHDIR}/#{manga}/#{chapter}/#{@page}.jpg"
		end
		
		if (!url_exits(url)) 
			@page = -1
			rename_files(manga, chapter, @arry)
			break;
		end
		
		@arry.push("#{@page}.jpg")
		download_image url, "#{@page}.jpg"
		puts("baixado: #{MHDIR}/#{manga}/#{chapter}/#{@page}.jpg.")
		@page += 1
	end
end
=end