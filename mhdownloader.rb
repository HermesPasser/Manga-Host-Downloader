#Manga Host Downloader
#by Hermes Passer in 2017-03-20

require 'fileutils'
require 'net/http'
require 'thread'

load 'search_pages.rb'
load 'downloader.rb'

VERSION = "1.0"
@log = ""

def putslog(text)
	@log = "\n#{@log}\n#{text}"
	puts text
end

def printlog(text)
	@log = "\n#{@log}#{text}"
	print text
end

def get_chapters(initial_chapter, final_chapter)
	c = initial_chapter
	arry = []
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
			putslog("renomeando arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}.")
		rescue Exception => e
			putslog "Não foi possivel renomear arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}.\nErro #{e}"
		end
		
		begin
			FileUtils.mv("#{manga} c#{chapter} p#{arry[i]}", "mangas/#{manga}/#{chapter}")
			putslog("movendo #{manga} c#{chapter} p#{arry[i]} para mangas/#{manga}/#{chapter}.")
		rescue Exception => ee
			putslog "Não foi possivel  mover #{manga} c#{chapter} p#{arry[i]} para mangas/#{manga}/#{chapter}.\nErro #{ee}"
		end
		
		i += 1
	end
end

def download_one(manga, chapter, use_multithreading)
	pages = Search_Pages.new(manga, chapter).get_pages
	@arry = Array.new

	if use_multithreading then threads = [] end
	if pages == -1 then return end # if chapter does exist
	
	pages.each do |page|
		if use_multithreading
			threads << Thread.new do
				url = "#{MHDIR}/#{manga}/#{chapter}/#{page}"
				Downloader.new(url, page)
			end
		else
			url = "#{MHDIR}/#{manga}/#{chapter}/#{page}"
			Downloader.new(url, page)
		end

	end

	if use_multithreading then threads.each(&:join) end
	rename_files(manga, chapter, pages)
end

def download_multiple(manga, arry_chapters, use_multithreading)
	putslog("Pegando capitulos intermediários...")
	arry_chapters.each do |c|
		download_one(manga,c, use_multithreading)
	end
end

def finish_operation(manga)
	FileUtils.mkdir_p("logs/")
	time_total = Time.now - @start
	h = (time_total / (60 * 60)).to_i
	m = ((time_total - (h * 60 * 60)) / 60).to_i
	s = (time_total - (h * 60 * 60) - (m * 60))
	dt = Time.now.strftime("%d-%m-%Y-%H-%M")
    putslog("Terminado em #{h} horas, #{m} minutos e #{s} segundos.")
	putslog("Log salvo em logs/#{manga}-#{dt}\nAperte qualquer tecla para continuar.")
	
	File.open("logs/#{manga}-#{dt}.txt", 'w') do |file| 
		file.write(@log.strip) 
	end

	gets
end

def use_multithreading?
	printlog("Usar multi-threading? (s/n)")
	usemt = gets.chomp!
	@start = Time.now
	return usemt == "s" ? true : false
end


while true
	Gem.win_platform? ? (system "cls") : (system "clear")
	putslog("\n\n\t\tManga Host Downloader #{VERSION}\n\tpor Hermes Passer - gladiocitrico.blogspot.com")
	putslog("\tO que deseja fazer? \n\t\t1 - baixar um capítulo\n\t\t2 - baixar vários capitulos\n\t\t3 - sair\n\n")
	@log = ""
	
	input = gets.chomp!
	if input == "1"
		printlog("Digite o nome do manga exatamente como está no mangahost: ")
		manga = gets.chomp!
		printlog("Digite nome\/número do capitulo: ")
		chapter = gets.chomp!
		
		if (manga == "" || chapter == "")
			putslog("Os campos não devem estar em branco!")
			next
		end
		
		manga = manga.downcase.gsub(" ", "-").gsub("(", "").gsub(")", "").gsub(":", "").strip
		download_one(manga, chapter, use_multithreading?)
		finish_operation(manga)
	elsif input == "2"
		printlog("Não serão aceitos capitulos que não tenham o seu nome em formato numerico.\nDigite o nome do manga exatamente como está no mangahost: ")
		manga = gets.chomp!
		printlog("Digite número do capitulo inicial: ")
		chapinit = gets.chomp!
		printlog("Digite número do capitulo final: ")
		chapend = gets.chomp!
		
		if (manga == "" || chapinit == "" || chapend == "")
			putslog("Os campos não devem estar em branco!")
			next
		end
		
		manga = manga.downcase.gsub(" ", "-").gsub("(", "").gsub(")", "").strip
		download_multiple(manga, get_chapters(chapinit.to_f, chapend.to_f), use_multithreading?)
		finish_operation(manga)
	elsif input == "3"
		break
	end
end