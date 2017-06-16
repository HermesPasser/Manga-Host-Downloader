#By Hermes Passer in 11/06/2017
require 'thread'
load 'external/updatewp.rb'
require_relative 'mdownloader/mhdownloader.rb'

include MDownloader
include Hermes::Update

$VERSION = "1.4"; $LOG = ""
manga = chap = path = ""
dont_execute = false

		
def update
	up = Hermes::Update::UpdateByWebPage.new("mhdownloader", $VERSION, "gladiocitrico.blogspot.com.br/p/update.html")
	if up.update_is_avaliable	
		if up.update
			puts($LOG ="Atualização baixada com sucesso! Por favor, delete tudo o que está na pasta onde o programa está instalado e desconpacte o arquivo master.zip.")
		else
			puts($LOG ="Não foi possível baixar a atualização, verifique sua conexão com a internet e tente novamente ou baixe direto do site.")
		end
	else
		puts($LOG ="Seu programa está atualizado.")
	end
end

def printlogo
	puts "\t    Manga Host Downloader #{$VERSION} Command Line"
	puts "\tby Hermes Passer (gladiocitrico.blogspot.com)"
end

def printhelp
	puts "Wrong number of parameters."
	puts "\nParameters: "
	puts "\tFor download: m:[manga_name], c:[chapter_name], p:[destination_path]."
	puts "\tHelp: h:"
	puts "\tUpdate: u:"
	puts "No parameters to open gui of program."
end

# printlogo
ARGV.each do |arg|
	arg_cmd = arg[0..1]
	case arg_cmd
	when "h:" 
		printhelp
		dont_execute = true
	when "u:"
		update
		dont_execute = true
	when "m:" then manga = arg[2, arg.length]
	when "c:" then chap  = arg[2, arg.length]
	when "p:" then path  = arg[2, arg.length]
	end
end

#reference
# mhd = Mangahost.new("", "tamen-de-gushi", "1")
# p mhd.get_cover
# download_one(manga, chap)
# d = MDownloader::Mangahost.new("C:\\Users\\Diogo\\Desktop", "tamen-de-gushi", "1")

if manga == "" && chap == "" && path == "" 
	if !dont_execute  
		if defined?(Shoes) then load "gui.rb"
		# else puts "To use the gui, run with Shoes"
		end
	end
else
	if MDownloader::Mangahost.url_page_exits?("mangahost.me", "/manga/#{manga}/")
		mhd = Mangahost.new(path, manga, chap)
		mhd.download_chapter
	else puts "\"mangahost.me/manga/#{manga}/\" cannot be found"
	end
end