# encoding: utf-8
# By Hermes Passer in 02/11/2017
require_relative 'mdownloader/mhdownloader.rb'
require 'fileutils'
load 	'external/updatewp.rb'
include MDownloader

VERSION = "1.7"; manga = chap = path = ""; dont_execute = false

def set_directory(dir)
	puts("Diretório padrão alterado com sucesso.\nPara reverte-lo para a pasta atual, use o comando sem especificar o caminho.")
	File::open("#{Dir.pwd}/config.txt", "w" ) { |arq| arq.write(dir)}
end

def get_directory(path)
	if File.exist?("#{Dir.pwd}/config.txt")
		File::open("#{Dir.pwd}/config.txt", "r" ) { |a| return a.read}
	else return File.dirname(__FILE__)
	end
end

def update
	up = Hermes::Update::UpdateByWebPage.new("mhdownloader", VERSION, "gladiocitrico.blogspot.com.br/p/update.html")
	if up.update_is_avaliable	
		if up.update
			puts("Atualização baixada com sucesso! Por favor, delete tudo o que está na pasta onde o programa está instalado e desconpacte o arquivo master.zip.")
		else
			puts("Não foi possível baixar a atualização, verifique sua conexão com a internet e tente novamente ou baixe direto do site.")
		end
	else puts("Seu programa está atualizado.")
	end
end

def printlogo
	puts "\t    Manga Host Downloader #{VERSION} Command Line"
	puts "\tby Hermes Passer (gladiocitrico.blogspot.com)"
end

def printhelp
	puts "\nVeja a imagem about.pgn para saber mais sobre como pegar o nome e capítulo do manga:"
	puts "\n\nArgumentos:"
	puts "\tPara download: m:[nome_manga], c:[nome_capítulo], p:[pasta_destino] (opcional)."
	puts "\tAlterar diretório padrão: d:"
	puts "\tAtualizar: u:"
	puts "\tAjuda: h:"
end

printlogo

ARGV.each do |arg|
	arg_cmd = arg[0..1]
	case arg_cmd
	when "h:"
		printhelp
		dont_execute = true
	when "u:"
		update
		dont_execute = true
	when "d:"
		dir = arg[2, arg.length]
			
		if dir == ""
			set_directory(File.dirname(__FILE__))
			FileUtils.remove_file("#{Dir.pwd}/config.txt") # isso não anula a linha de cima?
		else File.directory?(dir) ? set_directory(dir) : puts("Caminho inválido!")
		end
		
		dont_execute = true
	when "m:" then manga = arg[2, arg.length]
	when "c:" then chap  = arg[2, arg.length]
	when "p:" then path  = arg[2, arg.length]
	end
end

if manga == "" && chap == ""
	if !dont_execute  
		printhelp
	end
else
	
	if path == "" then path = get_directory(path) end
	path = "#{path}\\mangas\\#{manga}_#{chap}"
	FileUtils.mkdir_p(path)
	
	
	if !dont_execute && MDownloader::Mangahost.url_page_exits?("mangahost.me", "/manga/#{manga}/")
		start = Time.now
		
		mhd = Mangahost.new(path, manga, chap)
		mhd.download_chapter
		
		time_total = Time.now - start
		h = (time_total / (60 * 60)).to_i
		m = ((time_total - (h * 60 * 60)) / 60).to_i
		s = (time_total - (h * 60 * 60) - (m * 60))
		dt = Time.now.strftime("%d-%m-%Y-%H-%M")
		print("Terminado em #{h} horas, #{m} minutos e #{s} segundos.")
	else puts "\"mangahost.me/manga/#{manga}/\" não pode ser encontrado"
	end
end