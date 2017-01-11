#Manga Host Downloader
#by Hermes Passer in 2017-01-10

require 'open-uri'
require 'net/http'
require 'fileutils'

MHDIR = "http://img.mangahost.net/br/mangas_files/"

def url_exits(url_str)
	url = URI.parse(url_str)
  
	Net::HTTP.start(url.host, url.port) do |http|
		http.head(url.request_uri).code == '200'
	end

	rescue false
end

def download_image(url, page_name)
	open(page_name, 'wb') do |file|
		file << open(url).read
	end
end

def rename_files(manga, chapter, arry)
	FileUtils.mkdir_p("mangas/#{manga}/#{chapter}")

	i = 0
	s = ""
	while i < arry.length
		if i <= 9 then s = "0" else s = "" end
		
		File.rename(arry[i], "#{manga} c#{chapter} p#{s}#{arry[i]}")
		puts("renomeando arquivo #{arry[i]} para #{manga} c#{chapter} p#{s}#{arry[i]}.")
		
		FileUtils.mv("#{manga} c#{chapter} p#{s}#{arry[i]}", "mangas/#{manga}/#{chapter}")
		puts("movendo #{manga} c#{chapter} p#{s}#{arry[i]} para mangas/#{manga}/#{chapter}.")
		
		i += 1
	end
end

def download_one(manga, chapter)
	@page = 1
	@arry = Array.new
	while @page != -1
		if @page < 10
			url = "#{MHDIR}/#{manga}/#{chapter}/0#{@page}.jpg"
		else
			url = "#{MHDIR}/#{manga}/#{chapter}/#{@page}.jpg"
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
		puts("\n\nManga Host Downloader 0.1\nPor Hermes Passer - gladiocitrico.blogspot.com")
		puts("Somente serão baixados as paginas numerados pois este programa usa um loop para percorrer as paginas numeradas, ou seja, páginas como \"recrutamento\" não serão baixadas.")
		#puts("No modo baixar varios capitulos só baixados os capitulos numerados com numeros inteiros, capitulos com nomes diferentes como \"1.1\" terão que ser baixados pela opção baixar um capítulo.")
		puts("Alguns capitulos não começam com a primeira página tendo o número 1, neste caso, o capítulo será.")
		puts("Será adicionado um sistema para verificar a extenção das paginas do capítulo.")
		puts("Este programa reconhece o fim do capítulo quando a proxima imagem não existir, ou seja, pode ocorrer de o download seja abortado se o acesso a uma das imagens não for fornecido.")
	elsif input == "4"
		loop = false
	end
end