require_relative 'mdownloader/mhdownloader.rb'
require 'fileutils'
include MDownloader

# Execute o macro.bat para iniciar
nome_manga		 = "tamen-de-gushi" # O nome do manga deve estar dentro das aspas
capitulo_inicial = 2				# Somente funciona com capítulos numericos, ou seja capitulos
capitulo_final   = 4				# nomeados como one-shot, 23.4, extra-01 não serão baixados

downloader = Mangahost.new("", "", "")

for chap in capitulo_inicial..capitulo_final
	downloader.acess_url do
		puts "\nIniciando o download do capitulo #{chap}."
		path = "#{File.dirname(__FILE__)}\\mangas\\#{nome_manga}_#{chap}"
		FileUtils.mkdir_p(path)
		(Mangahost.new(path, nome_manga, chap)).download_chapter
	end
end
