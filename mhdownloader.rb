#Manga Host Downloader
#by Hermes Passer in 2017-01-10

load 'search_pages.rb'
load 'downloader.rb'
require 'fileutils'

def get_chapters(initial_chapter, final_chapter)
	c = initial_chapter
	arry = Array.new

	while c <= final_chapter + 1
		s = c.to_s
		
		if s.include?(".") and s[s.index(".") + 1] == "0"
			arry.push(c.to_i).to_s
		else
			arry.push(c.round(2).to_s)
		end
		c += 0.1
	end 

	return arry
end

def rename_files(manga, chapter, arry)
	FileUtils.mkdir_p("mangas/#{manga}/#{chapter}")

	i = 0
	while i < arry.length
		begin
			File.rename(arry[i], "#{manga} c#{chapter} p#{arry[i]}")
			puts("renomeando arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}.")
		rescue
			puts "Não foi possivel renomear arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}."
		end
		
		begin
			FileUtils.mv("#{manga} c#{chapter} p#{arry[i]}", "mangas/#{manga}/#{chapter}")
			puts("movendo #{manga} c#{chapter} p#{arry[i]} para mangas/#{manga}/#{chapter}.")
		rescue
			puts "Não foi possivel  mover #{manga} c#{chapter} p#{arry[i]} para mangas/#{manga}/#{chapter}."
		end
		
		i += 1
	end
end

def download_one(manga, chapter)
	pages = Search_Pages.new(manga, chapter).get_pages
	@arry = Array.new
	
	if pages == -1 then return end # if chapter does exist
	
	pages.each do |page|
		url = "#{MHDIR}/#{manga}/#{chapter}/#{page}"
		Downloader.new(url, page)
	end
	
	rename_files(manga, chapter, pages)
end

def download_multiple(manga, arry_chapters)
	arry_chapters.each do |c|
		download_one(manga,c)
	end
end

puts("\n\n\t\tManga Host Downloader 0.1\n\tpor Hermes Passer - gladiocitrico.blogspot.com")
loop = true

while loop
	puts("\tO que deseja fazer? \n\t\t1 - baixar um capítulo\n\t\t2 - baixar vários capitulos\n\t\t3 - notas\n\t\t4 - sair\n\n")
	input = gets.chomp!
	if input == "1"
		print("Digite o nome do manga exatamente como está no mangahost: ")
		manga = gets.chomp!
		print("Digite numero do capitulo: ")
		chapter = gets.chomp!
		
		if (manga == "" || chapter == "")
			puts("Os campos não devem estar em branco!")
			next
		end

		download_one(manga.downcase.gsub(" ","-").strip, chapter)
	elsif input == "2"
		print("Não serão aceitos capitulos que não tenham o seu nome em formato numerico.\nDigite o nome do manga exatamente como está no mangahost: ")
		manga = gets.chomp!
		print("Digite número do capitulo inicial: ")
		chaptinit = gets.chomp!
		print("Digite número do capitulo final: ")
		chaptend = gets.chomp!
		
		if (manga == "" || chaptinit == "" || chaptend == "")
			puts("Os campos não devem estar em branco!")
			next
		end

		download_multiple(manga.downcase.gsub(" ","-").strip, get_chapters(chaptinit.to_f, chaptend.to_f))
	elsif input == "3"
		puts("\n\nManga Host Downloader 0.5\nPor Hermes Passer - gladiocitrico.blogspot.com")
	elsif input == "4"
		loop = false
	end
end