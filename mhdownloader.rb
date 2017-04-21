# encoding: utf-8
# Manga Host Downloader
# by Hermes Passer in 2017-03-20

require 'fileutils'
require 'net/http'
require 'thread'

load 'external/updatewp.rb'
load 'internal/search_pages.rb'
load 'internal/downloader.rb'

VERSION = "1.3"
@directory = ""
@log = ""

def set_directory(dir)
	File::open("#{Dir.pwd}/config.txt", "w" ) do |arq|
		arq.write(dir)
	end
end

def update_directory
	if File.exist?("#{Dir.pwd}/config.txt")
		File::open("#{Dir.pwd}/config.txt", "r" ) do |arq|
			@directory = arq.read
		end
	else  @directory = Dir.pwd
	end
end

def putslog(text)
	@log = "\n#{@log}\n#{text}"
	puts text
end

def printlog(text)
	@log = "\n#{@log}#{text}"
	print text
end

def getslog
	t = gets
	@log = "\n#{@log}#{t}"
	return t
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
	FileUtils.mkdir_p("#{@directory}\\mangas\\#{manga}\\#{chapter}")

	i = 0
	while i < arry.length
		begin
			File.rename(arry[i], "#{manga} c#{chapter} p#{arry[i]}")
			putslog("renomeando arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}.")
		rescue Exception => e
			putslog "Não foi possivel renomear arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}.\nErro #{e}".encode("UTF-8", "Windows-1252")
		end
		
		begin
			FileUtils.mv("#{manga} c#{chapter} p#{arry[i]}", "#{@directory}\\mangas\\#{manga}\\#{chapter}")
			putslog("movendo #{manga} c#{chapter} p#{arry[i]} para #{@directory}\\mangas\\#{manga}\\#{chapter}".encode("UTF-8", "Windows-1252"))
		rescue Exception => ee
			putslog "Não foi possivel  mover #{manga} c#{chapter} p#{arry[i]} para #{@directory}\\mangas\\#{manga}\\#{chapter}.\nErro #{ee}".encode("UTF-8", "Windows-1252")
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
	time_total = Time.now - @start
	h = (time_total / (60 * 60)).to_i
	m = ((time_total - (h * 60 * 60)) / 60).to_i
	s = (time_total - (h * 60 * 60) - (m * 60))
	dt = Time.now.strftime("%d-%m-%Y-%H-%M")
    putslog("Terminado em #{h} horas, #{m} minutos e #{s} segundos.")
	putslog("Log salvo em #{@directory}\\logs\\#{manga}-#{dt}\nTecle enter para continuar.".encode("UTF-8", "Windows-1252"))
	
	FileUtils.mkdir_p("#{@directory}\\logs\\")
	File.open("#{@directory}\\logs\\#{manga}-#{dt}.txt", 'w') do |file| 
		file.write(@log.strip) 
	end

	gets
end

def use_multithreading?
	printlog("Usar multi-threading? (s/n) ")
	usemt = getslog.chomp!
	@start = Time.now
	return usemt == "s" ? true : false
end

def format_manga_name(manga)
	invalid = ["/","\\","\"","'","!","@","#","$","%","¨","&","*","(",")","+","=", ",", ":", ";", "°", "?", "[", "]", "~"]

	if manga[0] == "." then manga[0] = "" end
	if manga[manga.length-1] == "." then manga[manga.length-1] = "" end
	manga.downcase.gsub(".", "-")
	
	invalid.each do |i|
		manga.gsub(i, "")
	end

	return manga.gsub(" ", "-").gsub("  ", "-").gsub("--", "-").gsub(" - ", "-").gsub("é", "e").gsub("ô", "o").strip
end

update_directory
while true
	Gem.win_platform? ? (system "cls") : (system "clear")
	
	putslog("\n\n\t\tManga Host Downloader #{VERSION}\n\tpor Hermes Passer - gladiocitrico.blogspot.com")
	putslog("\tO que deseja fazer? \n\t\t1 - baixar um capítulo\n\t\t2 - baixar vários capitulos\n\t\t3 - alterar diretório padrão\n\t\t4 - atualizar\n\t\t5 - sair\n\n")
	input = getslog.chomp!
	@log = ""
	
	if input == "1"
		printlog("Digite o nome do manga exatamente como está no mangahost: ")
		manga = getslog.chomp!
		printlog("Digite nome\/número do capitulo: ")
		chapter = getslog.chomp!
		
		if (manga == "" || chapter == "")
			putslog("Os campos não devem estar em branco!")
			next
		end
		
		manga = format_manga_name(manga)
		download_one(manga, chapter, use_multithreading?)
		finish_operation(manga)
	elsif input == "2"
		printlog("Não serão aceitos capitulos que não tenham o seu nome em formato numerico.\nDigite o nome do manga exatamente como está no mangahost: ")
		manga = getslog.chomp!
		printlog("Digite número do capitulo inicial: ")
		chapinit = getslog.chomp!
		printlog("Digite número do capitulo final: ")
		chapend = getslog.chomp!
		
		if (manga == "" || chapinit == "" || chapend == "")
			putslog("Os campos não devem estar em branco!")
			next
		end
		
		manga = format_manga_name(manga)
		download_multiple(manga, get_chapters(chapinit.to_f, chapend.to_f), use_multithreading?)
		finish_operation(manga)
	elsif input == "3"
		puts("Escreva o caminho que você quer que seus mangás sejam salvos.\nDeixe vazio para que o diretorio padráo seja o diretório do programa.")
		
		while true
			dir = getslog.chomp!
			
			if dir == ""
				set_directory(Dir.pwd)
				FileUtils.remove_file("#{Dir.pwd}/config.txt")
				break
			else
				if File.directory?(dir)
					set_directory(dir)
					break
				else
					puts("Caminho inválido!")
				end
			end
		end
		
		update_directory
	elsif input == "4"
		up = Hermes::Update::UpdateByWebPage.new("mhdownloader", VERSION, "gladiocitrico.blogspot.com.br/p/update.html")
		if up.update_is_avaliable	
			if up.update
				puts("Atualização baixada com sucesso! Por favor, delete tudo o que está na pasta onde o programa está instalado e desconpacte o arquivo master.zip.")
			else
				puts("Não foi possível baixar a atualização, verifique sua conexão com a internet e tente novamente ou baixe direto do site.")
			end
		else
			puts("Seu programa está atualizado.")
		end
		puts("Tecle enter para continuar...")
		gets
	elsif input == "5"
		break
	end
end